<?php declare(strict_types=1);

namespace App\Tests\Unit\Controller\Jury;

use App\DataFixtures\Test\SampleSubmissionsFixture;
use App\Tests\Unit\BaseTest;
use Generator;

class SubmissionControllerTest extends BaseTest
{
    protected $roles = ['jury'];
    protected static $baseURL = '/jury/submissions';

    /**
     * Test that the basic building blocks of the index page are there.
     */
    public function testIndexBasic(): void
    {
        $this->verifyPageResponse('GET', static::$baseURL, 200);
    }

    /**
     * Test the filtered views have correct queries
     *
     * @dataProvider provideViews
     */
    public function testIndexViewFilter(string $filter, array $fixtures): void
    {
        $this->loadFixtures($fixtures);
        $this->verifyPageResponse('GET', static::$baseURL . '?view=' . $filter, 200);
    }

    public function provideViews(): Generator
    {
        foreach ([[], [SampleSubmissionsFixture::class]] as $fixtures) {
            foreach (['all', 'unjudged', 'unverified', 'newest'] as $view) {
                yield [$view, $fixtures];
            }
        }
    }

    /**
     * Test the filtered views have correct queries
     *
     * @dataProvider provideSubmissions
     */
    public function testJudgeRemaining(int $position, array $submission): void
    {
        // Load wrong submissions
        $this->loadFixture(SampleSubmissionsFixture::class);
        // Visit the submission page to see all the submissions
        $this->verifyPageResponse('GET', static::$baseURL, 200);
        $problemRow = $this->getCurrentCrawler()->filter('table.submissions-table tr')->eq($position);
        //var_dump()
        self::assertContains($submission[5], $problemRow->text());

        /*foreach($problemRows as $cnt=>$problemRow) {
            var_dump($cnt);
            //var_dump($problemRow->textContent);
            //var_dump($problemRow);
            //var_dump($problemRow->filter('td a')->getAttribute('href'));*/
            //var_dump(get_class_methods($problemRow));
            /*
            //var_dump(get_class_vars($problemRow));
            //var_dump($problemRow->getAttribute('href'));//->link()->getUri());
        }*/
        /*->eq($submissionId)->link()->getUri();
        $this->verifyPageResponse('GET', $link, 200);
        $selector = 'input#trigger-judge-remaining';
        $crawler = $this->getCurrentCrawler();
        var_dump($judging);
        var_dump($judging[5] !=='correct');
        var_dump($judging[6] > 1);
        if($judging[5] !== 'correct' && $judging[6] > 1) {
            //    var_dump($crawler->getUri());
            var_dump($crawler->html());
        }
        if($judging[5] === 'correct' || $judging[6] === 1) {
            self::assertSelectorNotExists($selector);
        } else {
            self::assertSelectorExists($selector);
        }*/
        //var_dump($crawler->text());
        //$linkf = $crawler->filter('table.submissions-table a')->first()->link()->getUri();
        //$linkl = $crawler->filter('table.submissions-table a')->last()->link()->getUri();
        //var_dump($crawler->text());
        //var_dump(static::$baseURL);
        //var_dump($link, $linkf, $linkl, $submissionId);
        //$links = $crawler->filter('a')->link()->getUri();
        //$links = $crawler->filter('a')->link()->getUri();
        //var_dump($links);
        //dump($links);
        /*foreach($links as $link) {
            var_dump($link);
        }*/
        //$this->verifyPageResponse('GET', static::$baseURL . '/' . $submissionId, 200);
        //if ($submission[5] === 'correct') {}
        // Check that for the first 2 the button is not available
        // Check that for the 2nd 2 the button is there
        // Check that when pressing the 1st button the 2nd is still available 
        $this->assertEquals(true,true);
    /*
     * When lazy evaluation is enabled testcases are evaluated until a non-correct
     * result is found. This tests that enabling further evaluation does not trigger
     * the evaluation for other submissions
     * 
     * @dataProvider provideViews
     */
    }

    public function provideSubmissions(): Generator
    {
        $submissionData = SampleSubmissionsFixture::$submissionData;
        foreach($submissionData as $index=>$item) {
            yield [count($submissionData)-1-$index,$item];
        }
    }
}
