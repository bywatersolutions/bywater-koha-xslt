<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin z3950 Admin Resident Search Box -->
<div id="header_search">
    <div id="z3950_search" class="residentsearch">
    <p class="tip">Z39.50/SRU server search:</p>
	<form action="/cgi-bin/koha/admin/z3950servers.pl" method="post">
                <input type="text" name="searchfield" size="40" value="[% searchfield %]" />
                <input type="submit" class="submit" name="search" value="Search" />
        </form>
	</div>

    [% INCLUDE 'patron-search-box.inc' %]

	[% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" value="Submit"  class="submit" />
		</form>
	</div>
	[% END %]
			<ul>
            <li><a href="#z3950_search">Search Z39.50/SRU servers</a></li>
            [% IF ( CAN_user_circulate ) %]<li><a href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>	
</div>
</div>
<!-- End Members Resident Search Box -->
