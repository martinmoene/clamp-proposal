<!--
-- Created: 21 May 2014, Martin Moene
--
-- Note 1: edited with MarkdownPad2 (http://markdownpad.com/).
-- Note 2: take care of trailing double space for formatting newline.
-- Note 3: the interspersed HTML is added to support generating useful output via Pandoc (http://johnmacfarlane.net/pandoc/).
--
-- IsoCpp: https://isocpp.org/std/library-design-guidelines
--
-- ISO/IEC JTC1 SC22 WG21 D*dddd* *yyyy-mm-dd*
-->

**Document number**: Nxxxx  
**Date**: 2015-xx-xx  
**Revises**: N4536  
**Project**: Programming Language C++, Library Evolution Working Group  
**Reply to**: Martin Moene &lt;martin.moene (at) gmail.com&gt;, Niels Dekker &lt;n.dekker (at) xs4all.nl&gt;  


An algorithm to "clamp" a value between a pair of boundary values
===================================================================

**Changes since N4536**  
Funtion `clamp_range()` is considered superfluous in view of the Ranges proposal and has been dropped from this proposal. 

<a name="contents"></a>

[Introduction](#introduction)  
[Motivation](#motivation)  
[Impact on the standard](#impact)  
[Comparison to clamp of Boost.Algorithm](#comparison)  
[Design decisions](#design)  
[Proposed wording](#wording)  
[Possible implementation](#implementation)  
[Acknowledgements](#acknowledgements)  
[References](#references)  


<a name="introduction"></a>

Introduction
--------------
The algorithm proposed here "clamps" a value between a pair of boundary values. The idea and interfaces are inspired by clamp in the Boost.Algorithm library authored by Marshall Clow.


<a name="motivation"></a>

Motivation
------------
It is a common programming task to constrain a value to fall within certain limits. This can be expressed in numerous ways, but it would be good if such an operation can be easily recognized and doesn't appear in many guises just because it can. 

So, we'd like to have a concise way to obtain a value that is forced to fall within a range we request, much like we can limit a value to a defined minimum or maximum. For example:
  
	auto clamped_value = clamp( value, min_value, max_value );

Without a standardized way, people may (need to) define their own version of "clamp" or resort to a less clear solution such as[^1]: 

	auto clamped_value = std::min( std::max( value, min_value ), max_value );

In addition to the boundary values, one can provide a predicate that evaluates if a value is within the boundary.
 
	struct rgb{ ... };
	
	auto clamped_rgb = clamp( rgb_value, rgb_lo, rgb_hi, rgb_compare );

Function `clamp()` already exists in C++ libraries such as Boost [[1]](#ref1) and Microsoft AMP [[2]](#ref2). The Qt Project provides `qBound` [[3]](#ref3) , and the Python library scipy/numpy provides `clip()` [[4]](#ref4) for the same purpose.


<a name="impact"></a>

Impact on the standard
------------------------
The clamp algorithms can be implemented as a pure library extension in C++14. The proposed wording is dependent on the void specialization of `<functional>`'s operator functors that is available since C++14 [[5]](#ref5)[[6]](#ref6).


<a name="comparison"></a>

Comparison to clamp of Boost.Algorithm
----------------------------------------
Our proposal defines a single function that can be used both with a user-defined predicate and without it. When no predicate is specified, the comparator defaults to `std::less<void>()`. The void specialization of `<functional>`'s operator functors introduced in C++14 enables comparison using the proper type [[5]](#ref5)[[6]](#ref6). 

Boost's clamp on the other hand was conceived before C++14 and uses two separate functions. Also, supporting compatibility with different versions of C++ is a reason for a Boost library to not require C++14-specific properties.

Like `std::min()` and `std::max()`, `clamp()` requires its arguments to be of the same  type, whereas, Boost's clamp accepts arguments of different type.

<a name="motivation"></a>

Design decisions
------------------
We chose the name *clamp* as it is expressive and is already being used in other libraries [^2]. Another name could be *limit*.

`clamp()` can be regarded as a sibling of `std::min()` and `std::max()`. This makes it desirable to follow their interface using constexpr, passing parameters by const reference and returning the result by const reference. Passing values by `const &` is desired for types that have a possibly expensive copy constructor such as `cpp_int` of Boost.Multiprecision [[7]](#ref7) and `std::seminumeric::integer` from the Proposal for Unbounded-Precision Integer Types [[8](#8)].

With the void specialization of `<functional>`'s operator functors available in C++14, we chose to combine the predicate and non-predicate versions into a single function and make `std::less<>()` its default comparator.


<a name="wording"></a>

Proposed wording
-------------------

<xdiv class="std">
<h3>X.Y.Z Bounded value<span style="float:right"> [alg.clamp]</span></h3>

```
template<class T, class Compare = std::less<>>
constexpr const T& clamp( const T& v, const T& lo, const T& hi, Compare comp = Compare() );
```
1 *Requires*: Type `T` is `LessThanComparable` (Table 18).  

2 *Returns*: The larger value of `v` and `lo` if `v` is smaller than `hi`, otherwise the smaller value of `v` and `hi`.  

3 *Complexity*: `clamp` will call `comp` either one or two times before returning one of the three parameters.  

4 *Remarks*: Returns the first argument when it is equivalent to one of the boundary arguments. 
</div>

<a name="implementation"></a>

Possible implementation
-------------------------
A reference implementation of this proposal can be found at GitHub [[9]](#ref9).

Clamp a value per predicate:

	template<class T, class Compare>
	constexpr const T& clamp( const T& val, const T& lo, const T& hi, Compare comp )
	{
	    return assert( !comp(hi, lo) ),
	        comp(val, lo) ? lo : comp(hi, val) ? hi : val;
	}


<a name="acknowledgements"></a>

Acknowledgements
------------------
Thanks to Marshall Clow for Boost.Algorithm's clamp which inspired this proposal and to Jonathan Wakely for his help with the proposing process.

<a name="references"></a>

References
---------------
<a name="ref1"></a>[1] Marshall Clow. [clamp in the Boost Algorithm Library](http://www.boost.org/doc/libs/1_58_0/libs/algorithm/doc/html/algorithm/Misc.html#the_boost_algorithm_library.Misc.clamp).   
Note: the Boost documentation shows `clamp()` using pass by value, whereas the actual code in [boost/algorithm/clamp.hpp](http://www.boost.org/doc/libs/1_58_0/boost/algorithm/clamp.hpp) uses `const &`. See [ticket 10081](https://svn.boost.org/trac/boost/ticket/10081).  
<a name="ref2"></a>[2] Microsoft. [C++ Accelerated Massive Parallelism library (AMP)](http://msdn.microsoft.com/en-us/library/hh265137.aspx).  
<a name="ref3"></a>[3] Qt Project. [Documentation on qBound](http://qt-project.org/doc/qt-5/qtglobal.html#qBound).  
<a name="ref4"></a>[4] Scipy.org. [Documentation on numpy.clip](http://docs.scipy.org/doc/numpy/reference/generated/numpy.clip.html).  
<a name="ref5"></a>[5] Stephan T. Lavavej. [Making Operator Functors greater<> (N3421, HTML)](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2012/n3421.htm). 2012-09-20.  
<a name="ref6"></a>[6] ISO/IEC. [Working Draft, Standard for Programming Language C++ (N4296, PDF)](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2014/n4296.pdf). Section 20.9.6. 2014-11-19.  
<a name="ref7"></a>[7] John Maddock. [Boost.Multiprecision](http://www.boost.org/doc/libs/1_55_0/libs/multiprecision/).  
<a name="8"></a>[8] Pete Becker. [Proposal for Unbounded-Precision Integer Types (N4038)](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2014/n4038.html).  
<a name="ref9"></a>[9] Martin Moene. [Clamp algorithm (GitHub)](https://github.com/martinmoene/clamp).  

[^1]: Or even:<pre><code>auto clamped_value = value;
if      ( value < min_value ) clamped_value = min_value;
else if ( value > max_value ) clamped_value = max_value;
</code></pre>

[^2]: As suggested by Jonathan Wakely on mailing list accu-general on 18 February 2014.
