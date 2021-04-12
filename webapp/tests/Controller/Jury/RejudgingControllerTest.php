<?php declare(strict_types=1);

namespace App\Tests\Controller\Jury;

use App\DataFixtures\Test\RejudgingStatesFixture;
use App\Tests\BaseTest;
use Generator;

class RejudgingControllerTest extends BaseTest
{
    /**
     * @dataProvider provideRoles
     */
    public function testStartPage(array $roles, int $http): void
    {
        static::$roles = $roles;
        $this->logOut();
        $this->logIn();
        $this->verifyPageResponse('GET', '/jury/rejudgings', $http);
        if($http===200) {
            foreach(['No rejudgings defined',' Add new rejudging','Rejudgings'] as $element) {
                self::assertSelectorExists('body:contains("'.$element.'")');
            }
        }
    }

    /**
     * Provide the HTTP access code for the DOMjudge role
     */
    public function provideRoles(): Generator
    {
        foreach(['admin','jury'] as $role) {
            yield [[$role],200];
        }
        foreach(['team','balloon','clarification_rw'] as $role) {
            yield [[$role],403];
        }
    }

    public function testCorrectSorting() : void
    {
        static::$roles = ['admin'];
        $this->loadFixture(RejudgingStatesFixture::class);
        $this->logOut();
        $this->logIn();
        $this->verifyPageResponse('GET', '/jury/rejudgings', 200);
        // The sorting is done in JS, this is the inverse ordering of the Fixture
        foreach(['Canceled','Finished','Unit'] as $index=>$reason)
        {
            self::assertSelectorExists('tr:nth-child('.($index+1).'):contains("'.$reason.'")');
        }
    }
}
