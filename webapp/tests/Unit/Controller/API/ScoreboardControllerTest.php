<?php declare(strict_types=1);

namespace App\Tests\Unit\Controller\API;

use App\DataFixtures\Test\DemoNonPublicContestFixture;
use App\DataFixturex\Test\ExtendDemoSessionTimeFixture;
use App\DataFixtures\Test\RemoveTeamFromDemoUserFixture;
use App\DataFixtures\Test\SampleEventsFixture;
use App\Entity\Contest;
use Generator;

class ScoreboardControllerTest extends BaseTestCase
{
    protected static array $fixtures = [ExtendDemoSessionTimeFixture::class, SampleEventsFixture::class];
    protected ?string $apiEndpoint = 'scoreboard';
    protected array $expectedObjects = [
        '1' => [
            "problem_id"   => "1",
            "from_team_id" => "2",
            "to_team_id"   => null,
            "reply_to_id"  => null,
            "time"         => "2018-02-11T21:47:18.901+00:00",
            "contest_time" => "-16525:12:41.098",
            "text"         => "Can you tell me how to solve this problem?",
        ],
        '2' => [
            "problem_id"   => "1",
            "from_team_id" => null,
            "to_team_id"   => "2",
            "reply_to_id"  => "1",
            "time"         => "2018-02-11T21:47:57.689+00:00",
            "contest_time" => "-16525:12:02.310",
            "text"         => "> Can you tell me how to solve this problem?\r\n\r\nNo, read the problem statement.",
        ],
    ];

    /**
     * Test that the given user has the correct access to the scoreboard for the given contest.
     *
     * @dataProvider provideScoreboardAccess
     */
    public function testScoreboardAccess(
        ?string $user, int $contestId, bool $removeTeamFromDemoUser, bool $expectedAllowedAccess, bool $publicContest
    ): void {
        if ($removeTeamFromDemoUser) {
            $this->loadFixture(RemoveTeamFromDemoUserFixture::class);
        }
        if (!$publicContest) {
            $this->loadFixture(DemoNonPublicContestFixture::class);
        }
        $contestId = $this->resolveEntityId(Contest::class, (string)$contestId);
        $url = "/contests/$contestId/scoreboard";
        $scoreboard = $this->verifyApiJsonResponse('GET', $url, $expectedAllowedAccess ? 200 : 404, $user);
        var_dump($scoreboard);
        self::assertNotEmpty($scoreboard);
    }

    public function provideScoreboardAccess(): Generator
    {
        // Contest 1 is a public contest, everyone should have access.
        yield [null, 1, false, true, true];
        yield ['demo', 1, false, true, true];
        yield ['demo', 1, true, true, true];
        yield ['admin', 1, false, true, true];

        // Contest 1 will be set to non public, not everyone will have access
        yield [null, 1, false, false, false];
        yield ['demo', 1, false, true, false];
        yield ['demo', 1, true, false, false];
        yield ['admin', 1, false, true, false];
    }

    /**
     * Test that filtering works on the demo scoreboard
     *
     * @dataProvider provideFilters
     */
    public function testFilteredScoreboard(array $filters, int $expectedCount): void
    {
        $contestId = $this->resolveEntityId(Contest::class, '1');
        $filter = '?'.implode('&', $filters);
        $url = "/contests/$contestId/scoreboard";
        $scoreboard = $this->verifyApiJsonResponse('GET', $url.$filter, 200, 'admin');
        /** @var array $scoreboardRows */
        $scoreboardRows = $scoreboard['rows'];
        self::assertNotEmpty($scoreboard);
        self::assertEquals($expectedCount, count($scoreboardRows));
    }

    public function provideFilters(): Generator
    {
        yield [['category=3'], 1];
        yield [['category=1', 'sortorder=9', 'allteams=true'], 1];
        yield [['category=1', 'sortorder=9'], 0];
        yield [['affiliation=1'], 1];
        yield [['public=true'], 1]; // Scoreboard is frozen but has no results so those are the same
        yield [['public=false'], 1];
        yield [['sortorder=0'], 1];
        yield [['sortorder=9','allteams=false'], 0];
        yield [['sortorder=9','allteams=true'], 1];
        yield [['sortorder=1','allteams=true'], 0];
        yield [['sortorder=999'], 0];
        yield [['allteams=false'], 1];
        yield [['allteams=true'], 1]; // Sortorder has default 0 -> hidden category system has 9
        yield [['country=NLD'], 1];
        yield [['country=AAA'], 0];
        yield [['country=USA'], 0];
        yield [['category=2'], 0];
    }

    /*public function testScoreboardContent(int $contestId): void
    {}

    public function provideScoreboardAccess(): Generator
    {
        yield [2, 2];
    }*/
}
