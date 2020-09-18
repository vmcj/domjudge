<?php declare(strict_types=1);

namespace App\Tests\Controller;

use App\Tests\BaseTest;

class ControllerRolesTest extends BaseTest
{
    protected static $roles = [];

    /**
     * //See: https://www.oreilly.com/library/view/php-cookbook/1565926811/ch04s25.html
     * Get all combinations of roles with at minimal the starting roles
     * @return array $results
     * @var string[] $possible_roles
     * @var string[] $start_roles
     */
    protected function roleCombinations(array $start_roles, array $possible_roles)
    {
        // initialize by adding the empty set
        $results = array($start_roles);

        foreach ($possible_roles as $element) {
            foreach ($results as $combination) {
                array_push($results, array_merge(array($element), $combination));
            }
        }
        return $results;
    }

    /*
     * Some URLs are not setup in the testing framework or have a function for the
     * user UX/login process, those are skipped.
     * @var string $url
     * @return boolean $includedInTest
     */
    public function urlExcluded(string $url)
    {
        // Documentation is not setup in the UnitTesting framework
        if (substr($url, 0, 4) == '/doc') {
            return true;
        }
        // API is not functional in Testing framework
        if (substr($url, 0, 4) == '/api') {
            return true;
        }
        // The change-contest handles a different action
        if (substr($url, 0, 21) == '/jury/change-contest/') {
            return true;
        }
        // Remove links to local page, external or application links
        if ($url[0] == '#' || strpos($url, 'http') !== false || $url == '/logout') {
            return true;
        }
        return false;
    }

    /**
     * Crawl the webpage assume this is allowed and return all other links on the page
     * @return string[] $urlsToCheck
     * @var string $url
     * @var int $statusCode
     */
    public function crawlPage(string $url, int $statusCode)
    {
        // We exclude some possible urls to not break the MockData
        if (strpos($url, '/delete') !== false) {
            return [];
        }
        // Documentation is not setup in the UnitTesting framework
        if (substr($url, 0, 4) == '/doc') {
            return [];
        }
        //Remove links to local page, external or application links
        if ($url[0] == '#' || strpos($url, 'http') !== false || $url == '/logout') {
            return [];
        }
        // This yields an error, disable for now
        if (strpos($url, '/jury/auditlog') !== false ||
            strpos($url, '/jury/import-export') !== false
        ) {
            return [];
        }
        // Downloading pdfs/text or binaries dirties the report
        // Nicer solution would be to know the mimetype from the headers
        if (
            strpos($url, '/text') !== false ||
            strpos($url, '/input') !== false ||
            strpos($url, '/output') !== false ||
            strpos($url, '/export') !== false ||
            strpos($url, '/download') !== false ||
            strpos($url, '.zip') !== false
        ) {
            return [];
        }
        $crawler = $this->client->request('GET', $url);
        $response = $this->client->getResponse();
        $message = var_export($response, true);
        $this->assertEquals($statusCode, $response->getStatusCode(), $message);
        return array_unique($crawler->filter('a')->extract(['href']));
    }

    /**
     * Test that having the role(s) gives access to all visible pages.
     * This test should detect mistakes where a page is disabled when the user has a
     * certain role instead of allowing when the correct role is there.
     * @var string[] $combinations
     * @var string[] $roleURLs
     */
    private function verifyAccess(array $combinations, array $roleURLs)
    {
        foreach ($combinations as static::$roles) {
            foreach ($roleURLs as $url) {
                if (
                    strpos($url, '/jury/change-contest/') !== false ||
                    strpos($url, 'activate') !== false ||
                    strpos($url, 'deactivate') !== false
                ) {
                    $this->crawlPage($url, 302);
                } else {
                    $this->crawlPage($url, 200);
                }
            }
        }
    }

    public function getAllPages(array $urlsToCheck)
    {
        $done = array();
        do {
            $toCheck = array_diff($urlsToCheck,$done);
            foreach ($toCheck as $url) {
                if (!$this->urlExcluded($url)) {
                    $urlsToCheck = array_unique(array_merge($urlsToCheck, $this->crawlPage($url, 200)));
                }
                $done[] = $url;
            }
        }
        while (array_diff($done,$urlsToCheck));
        return $urlsToCheck;
    }

    /**
     * Test that having the team role for example is enough to view pages of that role.
     * This test should detect mistakes where a page is disabled when the user has a
     * certain role instead of allowing when the correct role is there.
     * @var string $roleBaseURL The standard endpoint from where the user traverses the website
     * @var string[] $baseRoles The standard role of the user
     * @var string[] $optionalRoles The roles which should not restrict the viewable pages
     * @var boolean $allPages Should all possible pages be visited
     * @dataProvider provideBasePages
     */
    public function testRoleAccess(string $roleBaseURL, array $baseRoles, array $optionalRoles, bool $allPages)
    {
        static::$roles = $baseRoles;
        $this->logIn();
        $urlsToCheck = $this->crawlPage($roleBaseURL, 200);
        if ($allPages) {
            $urlsToCheck = $this->getAllPages($urlsToCheck);
        }
        $combinations = $this->roleCombinations($baseRoles, $optionalRoles);
        $this->verifyAccess($combinations, $urlsToCheck);
    }

    /** The test needs the data of which role to test with its base endpoint and the other optional roles/
     * We than check for the role admin which has as base endpoint
     * /jury if any combination with the other roles does forbide us from entering a page which the role can see
     * if its the only role.
     * For the first row: admin endpoint, [RoleName], [Other Optional roles], no traversing found links
     **/
    public function provideBasePages()
    {
        return [
            ['/jury', ['admin'],    ['jury','team'], false],
            ['/jury', ['jury'],     ['admin','team'], false],
            ['/team', ['team'],     ['admin','jury'], true]
        ];
    }

    /**
     * Test that having for example the jury role does not allow access to the pages of other roles.
     * @dataProvider provideBaseURLAndRoles
     * @var string $roleBaseURL The URL of the current Role
     * @var string[] $roleOthersBaseURL The BaseURLs of the other roles
     * @var string[] $role The tested Role,
     * @var string[] $rolesOther The other Roles
     * @var boolean $allPages Should all possible pages be visited
     */
    public function testRoleAccessOtherRoles(
        string $roleBaseURL,
        array $roleOthersBaseURL,
        array $role,
        array $rolesOther,
        bool $allPages
    ) {
        static::$roles = $rolesOther;
        $this->logIn();
        $urlsToCheck = [];
        foreach ($roleOthersBaseURL as $baseURL) {
            $urlsToCheck = array_merge($urlsToCheck, $this->crawlPage($baseURL, 200));
        }

        // Find all pages, currently this sometimes breaks as some routes have the same logic
        if ($allPages) {
            $urlsToCheck = $this->getAllPages($urlsToCheck);
        }

        // Now check the rights of our user with the current role
        static::$roles = $role;
        $this->logIn();
        $urlsToCheckRole = $this->crawlPage($roleBaseURL, 200);
        foreach (array_diff($urlsToCheck, $urlsToCheckRole) as $url) {
            if (!$this->urlExcluded($url)) {
                $this->crawlPage($url, 403);
            }
        }
    }

    /** The test needs the data of which role to test with its base endpoint and
     *  the endpoints of the other roles. We than check for the role admin which has as base endpoint
     * /jury if the endpoints of the other roles jur+team have other pages which we're allowed to access
     * so a Response: 200 but is not a link we have at our base endpoint
     * the last boolean is for following all found links.
     * For the first row: admin endpoint, [jury endpoint, team endpoint] adminRole, [OtherRoles], no traversing links
     **/
    public function provideBaseURLAndRoles()
    {
        return [
            ['/jury', ['/jury','/team'],    ['admin'],  ['jury','team'], false],
            ['/jury', ['/jury','/team'],    ['jury'],   ['admin','team'], false],
            ['/team', ['/jury'],            ['team'],   ['admin','jury'], true],
        ];
    }
}
