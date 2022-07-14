<?php declare(strict_types=1);

namespace App\Tests\Unit\Controller\Jury;

use App\Entity\Executable;
use Generator;

class ExecutableControllerTest extends JuryControllerTest
{
    protected static string  $identifyingEditAttribute = 'execid';
    protected static ?string $defaultEditEntityName    = 'adb';
    protected static string  $baseUrl                  = '/jury/executables';
    protected static array   $exampleEntries           = ['adb', 'run', 'boolfind run and compare'];
    protected static string  $shortTag                 = 'executable';
    protected static array   $deleteEntities           = ['adb','default run script','rb',
                                                          'default full debug script',
                                                          'boolfind run and compare'];
    protected static string  $deleteEntityIdentifier   = 'description';
    protected static string  $getIDFunc                = 'getExecid';
    protected static string  $className                = Executable::class;
    protected static array   $DOM_elements             = ['h1' => ['Executables']];
    protected static string  $addForm                  = 'executable_upload[';
    protected static array   $addEntitiesShown         = ['type'];
    protected static array   $addEntities              = [];

    /*public function provideDeletableEntities(): Generator
    {
        if (static::$delete !== '') {
            yield [static::$deleteEntities, ['Create dangling references in languages',
                                             'Create dangling references in problems']];
            yield [array_slice(static::$deleteEntities, 0, 1), ['Create dangling references in languages']];
            yield [array_reverse(static::$deleteEntities), ['Create dangling references in languages',
                                                            'Create dangling references in problems']];
            if (count(static::$deleteEntities) < 2) {
                $this->markTestIncomplete('Not enough entities to test multidelete');
            }
        } else {
            self::markTestSkipped("No deletable entities.");
        }
    }*/
}