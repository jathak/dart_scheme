part of cs61a_scheme.core.documentation;

Map<String, Docs> miscDocumentation = {
  "define": Docs.markdown(
      "**(define symbol expression)**\n\nEvaluates **expression** and binds it to **symbol** in the current environment.\n\n**(define (symbol params...) body...)**\n\nConstructs a lambda with **params** and **body** and binds it to **symbol**."),
  "if": Docs.markdown(
      "**(if predicate consequent *alternative*)**\n\nFirst evaluates **predicate**. If true, evaluates and returns **consequent**.\nOtherwise, evaluates and returns ***alternative*** if it exists."),
  "cond": Docs.markdown(
      "**(cond *clauses*...)**\nwhere each *clause* is **(test body...)**\n\nEvaluates the **test** of of each clause until one is true, in which case **body**\nis evaluated and returned. **else** may be substituted for the last **test**."),
  "and": Docs.markdown(
      "**(and expr...)**\n\nReturns the last **expr** if all are true, or short-circuits and returns it if\none is false."),
  "or": Docs.markdown(
      "**(or expr...)**\n\nReturns the last **expr** if all are false, or short-circuits and returns it if\none is true."),
  "let": Docs.markdown(
      "**(let (*bindings*) body...)**\nwhere each *binding* is **(symbol expr)**\n\nEvaluates **body** in a new environment with each **symbol** bound to its\ncorresponding expression."),
  "begin": Docs.markdown(
      "**(begin exprs...)**\n\nEvaluates each expr in sequence, returning the last one."),
  "lambda": Docs.markdown(
      "**(lambda (params...) body...)**\n\nConstructs a lambda procedure with some **body** that takes in **params**.\n\nLambda procedures are lexically scoped, which means they are evaluated in a\nchild of the frame the lambda was defined in."),
  "mu": Docs.markdown(
      "**(mu (params...) body...)**\n\nConstructs a mu procedure with some **body** that takes in **params**.\n\nUnlike lambdas, mu procedures are dynamically scoped, which means they are\nevaluated in a child of the frame the mu was called in."),
  "quote": Docs.markdown(
      "**(quote expr)**\n\nReturns **expr** without evaluating it.\n\n**'expr** is shorthand for the above."),
  "delay": Docs.markdown(
      "**(delay expr)**\n\nConstructs a promise from **expr**, delaying evaluation until forced."),
  "cons-stream": Docs.markdown(
      "**(cons-stream car cdr)**\n\nCreates a stream. Equivalent to **(cons car (delay cdr))**."),
  "define-macro": Docs.markdown(
      "**(define-macro (symbol params...) body...)**\n\nConstructs a macro and binds it to a symbol. See **(docs macros)** for more details."),
  "macros": Docs.markdown(
      "**Macros**\n\nA macro is a procedure that takes in pieces of code and returns a new piece of\ncode that will be evaluated in its place. The evaluation procedure is:\n\n1. Evaluate the operator, which should be a macro.\n2. Apply the macro to the unevaluated operands.\n3. Evaluate the code returned by the macro in the calling environment."),
  "set!": Docs.markdown(
      "**(set! symbol expr)**\n\nChanges the value of an existing binding of **symbol** to be the result of\nevaluating **expr**."),
  "quasiquote": Docs.markdown(
      "**(quasiquote expr)**\n\nWorks like **quote**, except that **expr** may contain calls to **unquote** that\nwill still be evaluated. **\\`expr** is shorthand for quasiquotation and **,expr** is\nshorthand for unquote.\n\nFor example **\\`(a ,b c)** would be evaluated so that the first and third items are\nthe symbols **a** and **c** but the second item is whatever **b** is bound to.")
};
