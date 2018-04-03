/// It's highly recommended to import this library with the prefix `logic`.
/// e.g. import 'package:cs61a_scheme/logic.dart' as logic;
/// This library does not depend on the implementation library.
library logic;

import 'package:cs61a_scheme/cs61a_scheme.dart';
export 'package:cs61a_scheme/cs61a_scheme.dart'
    show Pair, PairOrEmpty, SchemeSymbol, nil;

class LogicException extends SchemeException {
  LogicException([msg, showTrace, context]) : super(msg, showTrace, context);
}

class Variable extends SchemeSymbol {
  const Variable(String value) : super(value);
  factory Variable.fromSymbol(SchemeSymbol sym) {
    if (!sym.value.startsWith('?')) {
      throw new LogicException('Invalid variable $sym');
    }
    return new Variable(sym.value.substring(1));
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

  /// Converts so all symbols starting with '?' are converted to variables, and
  /// multiple references refer to the same variable instance.
  static Expression convert(Expression expr, [Set<Variable> found]) {
    if (found == null) found = new Set<Variable>();
    if (expr is Pair) {
      return new Pair(convert(expr.first, found), convert(expr.second, found));
    }
    if (expr is SchemeSymbol && expr.value.startsWith('?')) {
      for (var variable in found) {
        if (expr.value == '$variable') return variable;
      }
      var variable = new Variable.fromSymbol(expr);
      found.add(variable);
      return variable;
    }
    return expr;
  }

  toString() => '?$value';
}

class _Negation extends SelfEvaluating {
  const _Negation();

  toString() => 'not';
}

const not = const _Negation();

class Fact extends SelfEvaluating {
  final Pair conclusion;
  final Iterable<Pair> hypotheses;
  Fact._(this.conclusion, this.hypotheses);

  factory Fact(Expression conclusion, [Iterable<Expression> hypotheses]) {
    var found = new Set<Variable>();
    return new Fact._(Variable.convert(conclusion, found) as Pair,
        (hypotheses ?? []).map((h) => Variable.convert(h, found) as Pair));
  }
}

class Query extends SelfEvaluating {
  final Iterable<Pair> clauses;
  Query._(this.clauses);

  factory Query(Iterable<Expression> clauses) {
    var found = new Set<Variable>();
    return new Query._(clauses.map((h) => Variable.convert(h, found) as Pair));
  }
}

class Solution extends SelfEvaluating {
  final Map<Variable, Expression> assignments = {};

  toString() =>
      assignments.keys.map((v) => '${v.value}: ${assignments[v]}').join('\t');
}

class LogicEnv extends SelfEvaluating {
  final Solution partial = new Solution();
  final LogicEnv parent;

  LogicEnv(this.parent);

  Expression lookup(Variable variable) {
    if (partial.assignments.containsKey(variable)) {
      return partial.assignments[variable];
    }
    return parent?.lookup(variable);
  }

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
  var run = new _LogicRun(facts, depthLimit);
  for (LogicEnv env in run.searchQuery(query)) {
    var solution = new Solution();
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
    yield* search(query.clauses, new LogicEnv(null), 0);
  }

  search(Iterable<Pair> clauses, LogicEnv env, int depth) sync* {
    if (clauses.isEmpty) {
      yield env;
      return;
    }
    if (depth > depthLimit) return;
    Pair clause = clauses.first;
    if (clause.first == not) {
      var grounded = ground(clause.second, env) as Iterable<Pair>;
      if (search(grounded, env, depth).isEmpty) {
        var envHead = new LogicEnv(env);
        yield* search(clauses.skip(1), envHead, depth + 1);
      }
    } else {
      for (var fact in facts) {
        var envHead = new LogicEnv(env);
        if (unify(fact.conclusion, clause, envHead)) {
          for (var envRule in search(fact.hypotheses, envHead, depth + 1)) {
            yield* search(clauses.skip(1), envRule, depth + 1);
          }
        }
      }
    }
  }

  Expression ground(Expression expr, LogicEnv env) {
    while (expr is Variable) {
      expr = env.lookup(expr);
    }
    if (expr is Pair) {
      return new Pair(ground(expr.first, env), ground(expr.second, env));
    }
    return expr;
  }

  unify(Expression a, Expression b, LogicEnv env) {
    a = env.completeLookup(a);
    b = env.completeLookup(b);
    if (a == b) return true;
    if (a is Variable) {
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
