SQF stands for Status Quo Function - a successor of Status Quo Script, which is deprecated since Armed Assault but could still be used in Arma 3. SQF was first introduced in Operation Flashpoint: Resistance together with the call operator in update 1.85.


"Status Quo" was a code name for Operation Flashpoint
"Combined Arms" was a code name for Arma
"Futura" was a code name for Arma 3.


The SQF Language is fairly simple in how it is built. In fact: there are barely any actual language structures at all.

The functionality is provided via so called operators (or more commonly known scripting commands). Those operators are one of the following types: Nularsic, Unary, or Binary.



## Terminating an expression
An SQF expression has to be terminated via either ; (preferred by convention!) or ,.

> _num = 10; 
_num = _num + 20; systemChat str _num;
In the above example, there are three expressions:

> _num = 10
_num = _num + 20
systemChat str _num
All are separated by ; and not the line return - they could all be inlined and it would not impact the code.



# Brackets
>() - Round brackets are used to override the default Order of Precedence or improve legibility.
[] - Square brackets define Arrays.
{} - Curly brackets enclose instances of the Code Data Type. They are also used in Control Structures.


# Whitespaces
Whitespace consists of tabs and/or space characters.

For the
 purposes of the
   engine
     The 'line' begins at the first non whitespace character.
Similarly, trailing whitespace at the end of a line or statement is also ignored.



# Blank Lines
Blank lines are lines containing nothing but whitespace and are therefore ignored by the engine.



# Comments
A comment is additional text that gets ignored when a script is parsed. They serve as future reference and are often used to explain a specific part of the code.

In SQF, there are two kind of comments:

// in-line comment that ends on new line

/* block comment that can span above multiple lines
and ends on the following character combination: */
A comment can occur anywhere but inside a string. For example, the following would be valid:

1 + /* some random comment in an expression */ 1
It should be mentioned that there is a comment unary operator that should not be used as it will actually be executed (thus taking time to execute) but does nothing besides consuming a string. There is no benefit in using it and the reason it exists is solely for backward compatibility. Another way to make a comment that way, is to just place a string: /* some code */ "I can be considered as a comment but should not be used"; /* some other code */

Comments are removed during the preprocessing phase. This is important to know as that prevents usage in e.g a string that gets compiled using the compile unary operator or when only using loadFile.



# Nular Operators
A nularsic operator is more or less a computed variable. Each time accessed, it will return the current state of something. It is tempting to think of a nularsic operator as nothing more but a magic global variable, but it is important to differentiate!

Consider following example in a mission with e.g. 5 units:

// put the result of allUnits into a Variable
> _unitsArray = allUnits;

// display the current Array size using systemChat
> systemChat str count _unitsArray;

// create a new unit in the player group
>group player createUnit ["B_RangeMaster_F", getPosATL player, [], 0, "NONE"];

// output the Array size again
> systemChat str count _unitsArray;

// output the size of allUnits
>systemChat str count allUnits;

Now, what would the output of this look like?

>System: 5
System: 5
System: 6

As you can see, _unitsArray was not automatically updated as it would have been if it was not generated each time. If allUnits was just a global variable with a reference to some internal managed array, our private variable should have had reflected the change as value types are passed by reference. The reason for this is because allUnits and other nularsic operators just return the current state of something and do not return a reference to eg. an array containing all units. It is generated each time, which is why some of theese operators are more expensive to run then just using a variable.

# Unary Operators
The unary operators are operators that expect an argument on their right side (unary <argument>). They always will take the first argument that occurs.

A common mistake would be the following:

// create some Array containing three arrays
> _arr = [[1, 2, 3, 4, 5], [1, 2, 3, 4], [1, 2]];

// wrongly use the select operator to get the count of the > third array
> count _arr select 2; // error

Now, what went wrong?

Let's put some brackets in the right places to make the mistake understandable:

> (count _arr) select 2; // error
Due to the nature of unary operators, count instantly consumes our variable _arr and returns the number 3. The 3 then is passed to select which does not knows what to do with a number as left argument and thus errors out.

To do it correctly, one would have to put the _arr select 2 in brackets. The correct code thus would be:

// create an array containing three Arrays
> _arr = [[1, 2, 3, 4, 5], [1, 2, 3, 4], [1, 2]];

// use brackets to correctly get count of the third Array
> count (_arr select 2); // good :) will evaluate to 2


# Binary Operators
Binary operators expect two arguments (<1st argument> binary <2nd argument>) and are executed according to their precedence. If their precedence is equal, they are executed left to right.

As example, we will look into the following expression:

// create a nested Array with 5 levels
> _arr = [[[[[1]]]]];

// receive the nested number with some random math expressions
> _arr select 0 select 1 - 1 select 15 / 3 - 5 select 0 > select 10 * 10 + 4 * 0 - 100 // evaluates to 1

Now, let us analyze why this is happening for the first few expressions:

>_arr is loaded
0 is loaded
select is executed with the result of 1. & 2.
1 is loaded
1 is loaded
- is executed with the result of 4. & 5.
select is executed with the result of 3. & 6.
...
If we now would put brackets at the correct spots, the expression will get clearer:

> ((((_arr select 0) select (1 - 1)) select ((15 / 3) - 5)) select 0) select (((10 * 10) + (4 * 0)) - 100)

As you can see the * and / are executed first which matches their precedence. Afterward, the + and - operators will get executed followed by our select operator, which are executed from the left to the right.