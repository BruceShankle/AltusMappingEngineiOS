<a href="http://www.ba3.us/"><img src="./landing-github-ios.jpg"></a>

Announcement Valentine's Day 2014
=================================
Altus for iOS now supports ARC as well as ARM 64-bit.
We will be rolling out releases in stages as we add more test collateral from our non-ARC test harnesses.

We may also be moving Altus for iOS to a different git server due to the size of the fat binaries for creating an iOS framework.


You can download the current Altus ARC-compatible binaries for iOS
<a href="http://dev1.ba3.us/AltusARC_13c026a9f1.zip">here.</a>

This download includes a new ARC-compatible reference application called AltusDemo.
Also, the framework #import directive has changed from
<pre>
#import <ME/ME.h> </pre> to 
<pre>#import <AltusMappingEngine/AltusMappingEngine.h></pre>

See the AltusDemo xcode project for more details.

Happy Valentines Day,
The BA3 Team

<hr>

The BA3 Altus Mapping Engine(TM) is a high-performance library designed for iOS developers who are creating
both simple and demanding mapping apps for iPhones and iPads.
Developers using things like MapKit and Route-Me generally run into performance,
capacity or feature walls that block development, and the BA3 Mapping Engine can eliminate those walls.

Get the BA3 Altus SDK and Sample Applications
=============================================

Complete source code is supplied for all of the Altus Mapping Engine tutorials, 
and the tutorials themselves can be found in the 
<a href="http://www.ba3.us/?page=pages/knowledge-base">Knowledge Base</a>.
There is one code branch for each tutorial (e.g. "tutorial3"), as well as a "blankslate" branch that
has all of the libraries for the Altus Mapping Engine linked in, but no code (blankslate displays a white screen).
If this is your first time using these tutorials and you want to access the source code,
go to a command prompt and run these commands:

<pre>
git clone https://github.com/ba3llc/BA3MappingEngineTutorials.git
cd BA3MappingEngineTutorials
git checkout blankslate
</pre>


To get one of the tutorials, type:

<pre>
git checkout tutorial3 
</pre>

<b>About once a week, the SDK is updated with a new build of the Altus Mapping Engine,
any new tutorials and any necessary corrections.</b>

If it has been several weeks since you started the tutorials, or if you cannot checkout one of the tutorials,
you should get the latest version. To get the latest version, type:

<pre>
git checkout master
git pull
</pre>

Once you do that, you can checkout any of the tutorials as usual. 

Say that you are ready to move on to Tutorial 4, but you made minor modifications to the code in tutorial 3.
Git will not let you checkout tutorial4. In that case, you can type this to discard your changes:

<pre>
git reset --hard
git checkout tutorial4
</pre>

If you want to see a list of all of the source code available, type:

<pre>
git branch --list
</pre>

You can learn more about the BA3 Altus Mapping Engine at <a href="http://ba3.us">BA3.us</a>. Questions? Please send them to info@ba3.us
