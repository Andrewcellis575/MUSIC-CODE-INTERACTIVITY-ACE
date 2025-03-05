//-from-claude
there's a nuance about SuperCollider variable declaration that I didn't explain clearly.
In SuperCollider, there are actually two valid patterns for variable declaration:

Declare all variables at once at the top:
{
  var a, b, c;
  a = 1;
  b = 2;
  c = a + b;
  // rest of function
}

Declare and initialize variables as you go:
{
  var a = 1;
  var b = 2;
  var c = a + b;
  // rest of function
}


Both of these patterns are valid in SuperCollider. The examples you shared that compile fine are using the second pattern - declaring and initializing each variable as it's introduced.
What's not valid is mixing declaration and assignment for the same variable:
// This won't work:
{
  var a;
  a = 1;
  var b = 2;  // Can't declare new variables after assignments have begun
}
Or trying to declare a variable without the var keyword first:

// This won't work:
{
  a = 1;  // Error: 'a' is not declared
}
in a given scope, all variable declarations must come before any variable assignments that aren't part of a declaration.
Your examples work because they consistently use the "declare and initialize at the same time" pattern, which is perfectly valid SuperCollider code.