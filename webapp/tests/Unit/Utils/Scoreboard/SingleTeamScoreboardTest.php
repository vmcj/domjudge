<?php declare(strict_types=1);

namespace App\Tests\Unit\Utils\Scoreboard;

use App\Utils\Scoreboard\Scoreboard;
use PHPUnit\Framework\TestCase;

class SingleTeamScoreboardTest extends TestCase
{
    /**
     * Test that the scoreboard works with only a single team
     */
    public function testSingleTeamScoreboard() : void
    {
        $team = new Team();
        $score = new TeamScore($team);

        $sb = new Scoreboard();
        $sb->
    }
}
