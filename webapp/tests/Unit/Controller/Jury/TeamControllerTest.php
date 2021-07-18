<?php declare(strict_types=1);

namespace App\Tests\Unit\Controller\Jury;

use App\Entity\Team;

class TeamControllerTest extends JuryControllerTest
{
    protected static $baseUrl        = '/jury/teams';
    protected static $exampleEntries = ['exteam','DOMjudge','System','UU'];
    protected static $shortTag       = 'team';
    protected static $deleteEntities = ['name' => ['DOMjudge']];
    protected static $getIDFunc      = 'getTeamid';
    protected static $className      = Team::class;
    protected static $DOM_elements   = ['h1' => ['Teams']];
    protected static $addForm          = 'team_category[';
    protected static $addEntitiesShown = ['name'];
    protected static $addEntities      = [['name' => 'New Team',
                                           'displayName' => 'Display name',
                                           'icpcid' => '123',
                                           'category' => '1',
                                           'members' => 'Alice, Bob & Charlie',
                                           'affiliation' => '1',
                                           'penalty' => '100',
                                           'room' => 'Room 404',
                                           'Comments' => 'Team has additional equipment',
                                           'contests' => '1',
                                           'enabled' => '1',
                                           'addUserForTeam' => '1',
                                           'users' => ['0' => ['username' => 'teamuser']]]];

/*
team[name]	"Name"
team[displayName]	"Display"
team[icpcid]	"020"
team[category]	"1"
team[members]	"Members"
team[affiliation]	"1"
team[penalty]	"100"
team[room]	"Room404"
team[comments]	"Team+has+additional+equipment"
team[contests][]	"1"
team[enabled]	"1"
team[addUserForTeam]	"1"
team[users][0][username]	"teamuser"
team[save]	""*/
}
