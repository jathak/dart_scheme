# define

**(define symbol expression)**

Evaluates **expression** and binds it to **symbol** in the current environment.

**(define (symbol params...) body...)**

Constructs a lambda with **params** and **body** and binds it to **symbol**.

# if

**(if predicate consequent *alternative*)**

First evaluates **predicate**. If true, evaluates and returns **consequent**.
Otherwise, evaluates and returns ***alternative*** if it exists.

# cond

**(cond *clauses*...)**
where each *clause* is **(test body...)**

Evaluates the **test** of of each clause until one is true, in which case **body**
is evaluated and returned. **else** may be substituted for the last **test**.

# and

**(and expr...)**

Returns the last **expr** if all are true, or short-circuits and returns it if
one is false.

# or

**(or expr...)**

Returns the last **expr** if all are false, or short-circuits and returns it if
one is true.

# let

**(let (*bindings*) body...)**
where each *binding* is **(symbol expr)**

Evaluates **body** in a new environment with each **symbol** bound to its
corresponding expression.

# begin

**(begin exprs...)**

Evaluates each expr in sequence, returning the last one.

# lambda

**(lambda (params...) body...)**

Constructs a lambda procedure with some **body** that takes in **params**.

Lambda procedures are lexically scoped, which means they are evaluated in a
child of the frame the lambda was defined in.

# mu

**(mu (params...) body...)**

Constructs a mu procedure with some **body** that takes in **params**.

Unlike lambdas, mu procedures are dynamically scoped, which means they are
evaluated in a child of the frame the mu was called in.

# quote

**(quote expr)**

Returns **expr** without evaluating it.

**'expr** is shorthand for the above.

# delay

**(delay expr)**

Constructs a promise from **expr**, delaying evaluation until forced.

# cons-stream

**(cons-stream car cdr)**

Creates a stream. Equivalent to **(cons car (delay cdr))**.

# define-macro

**(define-macro (symbol params...) body...)**

Constructs a macro and binds it to a symbol. See **(docs macros)** for more details.

# macros

**Macros**

A macro is a procedure that takes in pieces of code and returns a new piece of
code that will be evaluated in its place. The evaluation procedure is:

1. Evaluate the operator, which should be a macro.
2. Apply the macro to the unevaluated operands.
3. Evaluate the code returned by the macro in the calling environment.

# set!

**(set! symbol expr)**

Changes the value of an existing binding of **symbol** to be the result of
evaluating **expr**.

# quasiquote

**(quasiquote expr)**

Works like **quote**, except that **expr** may contain calls to **unquote** that
will still be evaluated. **\`expr** is shorthand for quasiquotation and **,expr** is
shorthand for unquote.

For example **\`(a ,b c)** would be evaluated so that the first and third items are
the symbols **a** and **c** but the second item is whatever **b** is bound to.
