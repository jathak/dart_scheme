import 'package:test/test.dart';

import 'package:cs61a_scheme/logic.dart';

main() {
  group("logic", () {
    test("simple success", () {
      Fact fact = new Fact(clause(['likes', 'marvin', 'logic']));
      Query query = new Query([
        clause(['likes', 'marvin', 'logic'])
      ]);
      var solutions = evaluate(query, [fact]);
      expect(solutions, hasLength(1));
    });
    test("success with variables", () {
      Fact fact = new Fact(clause(['likes', 'marvin', 'logic']));
      Query query = new Query([
        clause(['likes', '?who', '?what'])
      ]);
      var solutions = evaluate(query, [fact]);
      expect(solutions, hasLength(1));
      var solution = solutionMap(solutions.first);
      expect(solution, hasLength(2));
      expect(solution['?who'], equals('marvin'));
      expect(solution['?what'], equals('logic'));
    });
    test("simple failure", () {
      Fact fact = new Fact(clause(['likes', 'marvin', 'logic']));
      Query query = new Query([
        clause(['likes', 'john', 'logic'])
      ]);
      var solutions = evaluate(query, [fact]);
      expect(solutions, isEmpty);
    });
    test("negation as failure", () {
      Fact fact = new Fact(clause(['equal', '?x', '?x']));
      Pair relation = clause(['equal', 'jen', '?x']);
      Query query = new Query(
          [new Pair(const SchemeSymbol('not'), new Pair(relation, nil))]);
      var solutions = evaluate(query, [fact]);
      expect(solutions, isEmpty);
    });
  });
}

PairOrEmpty clause(Iterable<String> parts) {
  if (parts.isEmpty) return nil;
  return new Pair(new SchemeSymbol(parts.first), clause(parts.skip(1)));
}

Map<String, String> solutionMap(Solution solution) {
  var map = <String, String>{};
  for (Variable variable in solution.assignments.keys) {
    map['$variable'] = solution.assignments[variable].toString();
  }
  return map;
}
