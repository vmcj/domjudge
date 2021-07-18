<?php declare(strict_types=1);

namespace App\Tests\Unit\Controller\Jury;

use App\Entity\Language;

class LanguagesControllerTest extends JuryControllerTest
{
    protected static $interest         = 'languages';
    protected static $baseUrl          = '/jury/languages';
    protected static $exampleEntries   = ['c','csharp','Haskell','Bash shell',"pas, p",'no','yes','R','r'];
    protected static $shortTag         = 'language';
    protected static $deleteEntities   = ['name' => ['C++']];
    protected static $getIDFunc        = 'getLangid';
    protected static $className        = Language::class;
    protected static $DOM_elements     = ['h1' => ['Languages']];
    protected static $addForm          = 'language[';
    protected static $addEntitiesShown = ['langid','externalid','name','timefactor'];
    protected static $addEntities      = [/*['langid' => 'nl',
                                           'externalid' => 'enl',
                                           'name' => 'New Language',
                                           'requireEntryPoint' => '1',
                                           'entryPointDescription' => '/entrypoint',
                                           'extensions' => ['ex'],
                                           'allowSubmit' => '1',
                                           'allowJudge' => '1',
                                           'timeFactor' => '1',
                                           'compileExecutable' => 'adb',
                                           'filterCompilerFiles' => '1']*//*,
                                          ['langid' => 'nent',
                                           'name' => 'No entrypoint',
                                           'requireEntryPoint' => '0',
                                           'entryPointDescription' => ''],
                                           ['langid' => 'nent',
                                           'name' => 'No entrypoint',
                                           'requireEntryPoint' => '0',
                                           'entryPointDescription' => ''],
                                           ['langid' => 'nsb',
                                           'name' => 'No submit',
                                           'allowSubmit' => '0'],
                                           ['langid' => 'nju',
                                           'name' => 'No judge',
                                           'allowJudge' => '0'],
                                           ['langid' => 'nsl',
                                           'name' => 'Slow language',
                                           'timeFactor' => '3.9'],
                                           ['langid' => 'ncmp',
                                           'name' => 'No compilation',
                                           'compileExecutable' => ''],
                                           ['langid' => 'nflt',
                                           'name' => 'No filter',
'filterCompilerFiles' => '0']*/]; // TODO: Extensions not implemented
}
