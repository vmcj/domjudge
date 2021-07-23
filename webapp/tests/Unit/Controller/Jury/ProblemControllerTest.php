<?php declare(strict_types=1);

namespace App\Tests\Unit\Controller\Jury;

use App\DataFixtures\Test\AddProblemAttachmentFixture;
use App\Entity\Problem;

class ProblemControllerTest extends JuryControllerTest
{
    protected static $baseUrl                 = '/jury/problems';
    protected static $exampleEntries          = ['Hello World', 'default',5,3,2,1];
    protected static $shortTag                = 'problem';
    protected static $deleteEntities          = ['name' => ['Hello World']];
    protected static $getIDFunc               = 'getProbid';
    protected static $className               = Problem::class;
    protected static $DOM_elements            = ['h1' => ['Problems'],
                                                 'a.btn[title="Import problem"]' => ['admin' => [" Import problem"],'jury'=>[]]];
    protected static $identifingEditAttribute = 'name';
    protected static $defaultEditEntityName   = 'Participants';
    protected static $deleteExtra             = ['pageurl'   => '/jury/problems/3',
                                                 'deleteurl' => '/jury/problems/attachments/1/delete',
                                                 'selector'  => 'interactor',
                                                 'fixture'   => AddProblemAttachmentFixture::class];
    protected static $addForm                 = 'problem[';
    protected static $addEntitiesShown        = ['name'];
    protected static $addEntities             = [['name' => 'Problem',
                                                 'timelimit' => '1',
                                                 'memlimit' => '1073741824',
                                                 'outputlimit' => '1073741824',
                                                 'problemtextFile' => '',
                                                 'runExecutable' => 'boolfind_run',
                                                 'compareExecutable' => 'boolfind_cmp',
                                                 'specialCompareArgs' => ''],
                                                ['name' => 'Long time',
                                                 'timelimit' => '3600'],
                                                ['name' => 'Default limits',
                                                 'memlimit' => '', 'outputlimit' => ''],
                                                ['name' => 'Args',
                                                 'specialCompareArgs' => 'args'],
                                                /*['name' => 'Contest with problems',
                                                 'problems' => [
                                                     '0' => ['problem' => '2',
                                                             'shortname' => 'fcmp',
                                                             'points' => '2',
                                                             'allowSubmit' => '1',
                                                             'allowJudge' => '1',
                                                             'color' => '#000000',
                                                             'lazyEvalResults' => '0'],
                                                     '1' => ['problem' => '1',
                                                             'shortname' => 'hw',
                                                             'points' => '1',
                                                             'allowSubmit' => '0',
                                                             'allowJudge' => '1',
                                                             'color' => '#000000',
                                                             'lazyEvalResults' => '0'],
                                                     '2' => ['problem' => '3',
                                                             'shortname' => 'p3',
                                                             'points' => '1',
                                                             'allowSubmit' => '1',
                                                             'allowJudge' => '0',
                                                             'color' => 'yellow',
                                                 'lazyEvalResults' => '1']]]*/];
}
