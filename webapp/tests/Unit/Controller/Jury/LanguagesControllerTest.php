<?php declare(strict_types=1);

namespace App\Tests\Unit\Controller\Jury;

use App\Entity\Language;

class LanguagesControllerTest extends JuryControllerTest
{
    protected static $identifingEditAttribute = 'name';
    protected static $defaultEditEntityName   = 'Java';
    protected static $baseUrl          = '/jury/languages';
    protected static $exampleEntries   = ['c','csharp','Haskell','Bash shell',"pas, p",'no','yes','R','r'];
    protected static $shortTag         = 'language';
    protected static $deleteEntities   = ['name' => ['C++']];
    protected static $getIDFunc        = 'getLangid';
    protected static $className        = Language::class;
    protected static $DOM_elements     = ['h1' => ['Languages']];
    protected static $addPlus          = 'extensions';
    protected static $addForm          = 'language[';
    protected static $addEntitiesShown = ['langid','externalid','name','timefactor'];
    protected static $addEntities      = [/*['langid' => 'simple',
    'externalid' => 'simple',
    'name' => 'Simple',
    'requireEntryPoint' => '0',
    'entryPointDescription' => '',
    'allowSubmit' => '1',
    'allowJudge' => '1',
    'timeFactor' => '1',
    'compileExecutable' => 'java_javac',
    'extensions' => ['0' => 'extension'],
    'filterCompilerFiles' => '1'],
   ['langid' => 'ext',
    'externalid' => 'diffext',
    'name' => 'External'],*/
   /*['langid' => 'entry',
    'requireEntryPoint' => '1',
    'entryPointDescription' => 'shell'],
   ['langid' => 'nosub',
    'allowSubmit' => '0'],
   ['langid' => 'nojud',
    'allowJudge' => '0'],
   ['langid' => 'timef1',
    'timeFactor' => '3'],
   ['langid' => 'timef2',
    'timeFactor' => '1.3'],
   ['langid' => 'timef3',
    'timeFactor' => '0.5'],
   ['langid' => 'comp',
    'compileExecutable' => 'java_javac'],
   ['langid' => 'multex',
    'extensions' => ['0' => 'a',
                     '1' => 'b',
                     '2' => '1',
                     '3' => ',']],
   ['langid' => 'nofilt',
'filterCompilerFiles' => '0']*/];
}
