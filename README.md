<!--
-- Created: 21 May 2014, Martin Moene
--
-- Note 1: the interspersed HTML is added to support generating useful output via Pandoc.
-- Note 2: edited with MarkdownPad2 (http://markdownpad.com/).
-->

An algorithm to "clamp" a value between a pair of boundary values  (Revision -1)
==================================================================================

ISO/IEC JTC1 SC22 WG21 D*dddd* *yyyy-mm-dd* 

*Martin Moene, martin.moene (at) gmail.com*  
*Niels Dekker, n.dekker (at) xs4all.nl*

**Contents**  
[Introduction](#introduction)  
[Motivation](#motivation)  
[Impact On the Standard](#impact)  
[Comparison to clamp of Boost.Algorithm](#comparison)  
[Design Decisions](#design)  
[Technical Specifications / Standardese](#specifications)  
[Possible Implementation](#implementation)  
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
 
	[@Niels: convincing predicate example ?]

Besides the algorithm to clamp a single value, there is an algorithm to clamp a series of values: 

	std::vector<int> a{ 1,2,3,4,5,6,7,8,9 };
	
	auto out = clamp_range( a.begin(), a.end(), a.begin(), 3, 7 );

Again, a predicate can be provided that evaluates if a value is within the boundary:

	[@Niels: image processing example ?]

Function `clamp()` already exists in C++ libraries such as Boost [[1]](#ref1) and Microsoft AMP [[2]](#ref2). The Qt Project provides `qBound` [[3]](#ref3) , and the Python library scipy/numpy provides `clip()` [[4]](#ref4) for the same purpose.


<a name="impact"></a>

Impact On the Standard
------------------------
The clamp algorithms require no changes to the core language and break no existing code. The proposed wording is dependent on the void specialization of `<functional>`'s operator functors that is available since C++14 [[5]](#ref5)[[6]](#ref6).


<a name="comparison"></a>

Comparison to clamp of Boost.Algorithm
----------------------------------------
Our proposal defines a single function that can be used both with a user-defined predicate and without it. When no predicate is specified, the comparator defaults to `std::less<void>()`. The void specialization of `<functional>`'s operator functors introduced in C++14 enables comparison using the proper type [[5]](#ref5)[[6]](#ref6). 

Boost's clamp on the other hand was conceived before C++14 and uses two separate functions. Also, supporting compatibility with different versions of C++ is a reason for a Boost library to not require C++14-specific properties.


<a name="motivation"></a>

Design Decisions
------------------
We chose the name *clamp* as it is expressive and is already being used in other libraries [^2]. Another name could be *limit*. Other names for *clamp_range* could be *clamp_elements*, or *clamp_transform*.

`clamp()` can be regarded as a sibling of `std::min()` and `std::max()`. This makes it desirable to follow their interface using constexpr, passing parameters by const reference and returning the result by const reference.

[@Niels: write about benefit of returning by `const &` ?]

With the void specialization of `<functional>`'s operator functors available in C++14, we chose to combine the predicate and non-predicate versions into a single function and make `std::less<>()` its default comparator.


<a name="specifications"></a>

Technical Specifications / Standardese
----------------------------------------
Clamp a value per predicate, default `std::less<>`:

	template<class T, class Compare = std::less<>>
	constexpr const T& clamp( const T& val, const T& lo, const T& hi, Compare comp = Compare() );
	
Clamp a range of values per predicate, default `std::less<>`:
	
	template<class InputIterator, class OutputIterator, class Compare = std::less<>>
	OutputIterator clamp_range( InputIterator first, InputIterator last, OutputIterator out,
	    typename std::iterator_traits<InputIterator>::value_type const& lo,
	    typename std::iterator_traits<InputIterator>::value_type const& hi, Compare comp = Compare() );


<a name="implementation"></a>

Possible Implementation
-------------------------
This proposal can be implemented as pure library extension in C++14. A reference implementation of this proposal can be found at GitHub [[7]](#ref7).

Clamp a value per predicate:

	template<class T, class Compare>
	constexpr const T& clamp( const T& val, const T& lo, const T& hi, Compare comp )
	{
	    return assert( !comp(hi, lo) ),
	        comp(val, lo) ? lo : comp(hi, val) ? hi : val;
	}

Clamp range of values per predicate:

	template<class InputIterator, class OutputIterator, class Compare>
	OutputIterator clamp_range(
	    InputIterator first, InputIterator last, OutputIterator out,
	    typename std::iterator_traits<InputIterator>::value_type const& lo,
	    typename std::iterator_traits<InputIterator>::value_type const& hi, Compare comp )
	{
	    using arg_type = decltype(lo);
	
	    return std::transform(
	        first, last, out, [&](arg_type val) -> arg_type { return clamp(val, lo, hi, comp); } );
	}


<a name="acknowledgements"></a>

Acknowledgements
------------------
TBD

<a name="references"></a>

References
---------------
<a name="ref1"></a>[1] Marshall Clow. [clamp in the Boost Algorithm Library](http://www.boost.org/doc/libs/1_55_0/libs/algorithm/doc/html/algorithm/Misc.html#the_boost_algorithm_library.Misc.clamp).   
Note: the Boost documentation shows `clamp()` returning a value, whereas the actual code in [boost/algorithm/clamp.hpp](http://www.boost.org/doc/libs/1_55_0/boost/algorithm/clamp.hpp) returns a `const &`. See [ticket 10081](https://svn.boost.org/trac/boost/ticket/10081).  
<a name="ref2"></a>[2] Microsoft. [C++ Accelerated Massive Parallelism library (AMP)](http://msdn.microsoft.com/en-us/library/hh265137.aspx).  
<a name="ref3"></a>[3] Qt Project. [Documentation on qBound](http://qt-project.org/doc/qt-5/qtglobal.html#qBound).  
<a name="ref4"></a>[4] Scipy.org. [Documentation on numpy.clip](http://docs.scipy.org/doc/numpy/reference/generated/numpy.clip.html).  
<a name="ref5"></a>[5] Stephan T. Lavavej. [Making Operator Functors greater<> (N3421, HTML)](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2012/n3421.htm). 2012-09-20.  
<a name="ref6"></a>[6] ISO/IEC. [Working Draft, Standard for Programming Language C++ (N3797, PDF)](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2013/n3797.pdf). Section 20.9.5. 2013-10-13.  
<a name="ref7"></a>[7] Martin Moene. [Clamp algorithm (GitHub)](https://github.com/martinmoene/clamp).  

[^1]: Or even:<pre><code>auto clamped_value = value;
if      ( value < min_value ) clamped_value = min_value;
else if ( value > max_value ) clamped_value = max_value;
</code></pre>

[^2]: As suggested by Jonathan Wakeley on mailing list accu-general on 18 February 2014.
