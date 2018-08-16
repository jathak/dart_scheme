/// It's highly recommended to import this library with the prefix `logic`.
/// e.g. import 'package:cs61a_scheme/logic.dart' as logic;
/// This library does not depend on the implementation library.
library logic;

import 'package:quiver/core.dart' show hash2;

import 'package:cs61a_scheme/cs61a_scheme.dart';
export 'package:cs61a_scheme/cs61a_scheme.dart'
    show Pair, PairOrEmpty, SchemeSymbol, nil;

class LogicException extends SchemeException {
  LogicException([msg, showTrace, context]) : super(msg, showTrace, context);
}

int _globalCounter = 0;

class Variable extends SelfEvaluating {
  final String value;
  int tag;
  Variable(this.value);

  factory Variable.fromSymbol(SchemeSymbol sym) {
    if (!sym.value.startsWith('?')) {
      throw LogicException('Invalid variable $sym');
    }
    return Variable(sym.value.substring(1));
  }

  /// Finds all variables in a given input
  static Iterable<Variable> findIn(Expression input) sync* {
    if (input is Query) {
      for (Pair relation in input.clauses) {
        yield* findIn(relation);
      }
    } else if (input is Fact) {
      yield* findIn(input.conclusion);
      for (Pair relation in input.hypotheses) {
        yield* findIn(relation);
      }
    } else if (input is Pair) {
      yield* findIn(input.first);
      yield* findIn(input.second);
    } else if (input is Variable) {
      yield input;
    }
  }

  bool operator ==(v) => v is Variable && value == v.value && tag == v.tag;

  int get hashCode => hash2(value, tag);

  /// Converts so all symbols starting with '?' are converted to variables
  static Expression convert(Expression expr, [int tag]) {
    if (expr is Pair) {
      return Pair(convert(expr.first, tag), convert(expr.second, tag));
    } else if (expr is SchemeSymbol && expr.value.startsWith('?')) {
      return Variable.fromSymbol(expr)..tag = tag;
    } else if (expr is SchemeSymbol && expr.value == 'not') {
      return not;
    } else if (expr is Variable) {
      return Variable(expr.value)..tag = tag;
    }
    return expr;
  }

  toString() => '?$value${tag ?? ""}';

  String toProlog() => 'V_' + value.replaceAll('-', '_');
}

class _Negation extends SelfEvaluating {
  const _Negation();

  toString() => 'not';
}

const not = _Negation();

class Fact extends SelfEvaluating {
  final Pair conclusion;
  final Iterable<Pair> hypotheses;

  factory Fact(Expression conclusion,
          [Iterable<Expression> hypotheses, int tag]) =>
      Fact._(Variable.convert(conclusion, tag) as Pair,
          (hypotheses ?? []).map((h) => Variable.convert(h, tag) as Pair));

  Fact._(this.conclusion, this.hypotheses);

  String toProlog() {
    var prologConclusion = _relationToProlog(conclusion);
    if (hypotheses.isEmpty) {
      return '$prologConclusion.';
    } else {
      var prologHypotheses = hypotheses.map(_relationToProlog).join(',\n  ');
      return '$prologConclusion :-\n  $prologHypotheses.';
    }
  }

  static String _relationToProlog(Pair p) {
    if (p.first == not) {
      return '\\+ ' + _exprToProlog(p.second);
    }
    return '${_exprToProlog(p.first)}(${_exprToProlog(p.second)})';
  }

  static String _exprToProlog(Expression expr, [bool inPair = false]) {
    if (expr is Pair) {
      var first = _exprToProlog(expr.first);
      var second = _exprToProlog(expr.second, true);
      var inner = '$first|$second';
      if (expr.second is Pair) inner = '$first, $second';
      if (expr.second == nil) inner = '$first';
      return inPair ? inner : '[$inner]';
    } else if (expr is Variable) {
      return expr.toProlog();
    } else if (expr == nil) {
      if (inPair) return '';
      return '[]';
    } else {
      var converted = expr.toString().replaceAll('-', '_');
      if (RegExp(r'^[a-z]\w*$').hasMatch(converted)) {
        return converted;
      }
      return "'$expr'";
    }
  }
}

class Query extends SelfEvaluating {
  final Iterable<Pair> clauses;

  factory Query(Iterable<Expression> clauses) =>
      Query._(clauses.map((h) => Variable.convert(h) as Pair));

  Query._(this.clauses);
}

class Solution extends SelfEvaluating {
  final Map<Variable, Expression> assignments = {};

  toString() =>
      assignments.keys.map((v) => '${v.value}: ${assignments[v]}').join('\t');
}

class LogicEnv extends SelfEvaluating {
  final Solution partial = Solution();
  final LogicEnv parent;

  LogicEnv(this.parent);

  Expression lookup(Variable variable) =>
      partial.assignments[variable] ?? parent?.lookup(variable);

  Expression completeLookup(Expression expr) {
    if (expr is Variable) {
      var result = lookup(expr);
      if (result == null) return expr;
      return completeLookup(result);
    }
    return expr;
  }
}

Iterable<Solution> evaluate(Query query, List<Fact> facts,
    [int depthLimit = 50]) sync* {
  var run = _LogicRun(facts, depthLimit);
  for (LogicEnv env in run.searchQuery(query)) {
    var solution = Solution();
    for (var variable in Variable.findIn(query)) {
      solution.assignments[variable] = run.ground(variable, env);
    }
    yield solution;
  }
}

class _LogicRun {
  final List<Fact> facts;
  final int depthLimit;

  _LogicRun(this.facts, this.depthLimit);

  Iterable<LogicEnv> searchQuery(Query query) sync* {
    _globalCounter = 0;
    yield* search(query.clauses, LogicEnv(null), 0);
  }

  Iterable<LogicEnv> search(
      Iterable<Pair> clauses, LogicEnv env, int depth) sync* {
    if (clauses.isEmpty) {
      yield env;
      return;
    }
    if (depth > depthLimit) return;
    Pair clause = clauses.first;
    if (clause.first == not) {
      var grounded = ground(clause.second, env).pair.map((expr) => expr.pair);
      if (search(grounded, env, depth).isEmpty) {
        var envHead = LogicEnv(env);
        yield* search(clauses.skip(1), envHead, depth + 1);
      }
    } else {
      for (var fact in facts) {
        fact = Fact(fact.conclusion, fact.hypotheses, _globalCounter++);
        var envHead = LogicEnv(env);
        if (unify(fact.conclusion, clause, envHead)) {
          for (var envRule in search(fact.hypotheses, envHead, depth + 1)) {
            yield* search(clauses.skip(1), envRule, depth + 1);
          }
        }
      }
    }
  }

  Expression ground(Expression expr, LogicEnv env) {
    if (expr is Variable) {
      var resolved = env.lookup(expr);
      if (resolved == null || expr == resolved) {
        return expr;
      }
      return ground(resolved, env);
    }
    if (expr is Pair) {
      return Pair(ground(expr.first, env), ground(expr.second, env));
    }
    return expr;
  }

  unify(Expression a, Expression b, LogicEnv env) {
    a = env.completeLookup(a);
    b = env.completeLookup(b);
    if (a == b) {
      return true;
    } else if (a is Variable) {
      env.partial.assignments[a] = b;
      return true;
    } else if (b is Variable) {
      env.partial.assignments[b] = a;
      return true;
    } else if (a is Pair && b is Pair) {
      return unify(a.first, b.first, env) && unify(a.second, b.second, env);
    }
    return false;
  }
}
