<?php declare(strict_types=1);

namespace App\Tests\Unit\Command;

use Generator;
use InvalidArgumentException as GlobalInvalidArgumentException;
use Symfony\Component\Console\Exception\InvalidArgumentException;

use App\Service\ConfigurationService;
use Symfony\Bundle\FrameworkBundle\Console\Application;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Symfony\Component\Console\Tester\CommandTester;
use Exception;

class CheckDatabaseConfigurationDefaultValuesCommandTest extends CommandTest
{
    protected static $commandName = 'domjudge:db-config:check';

    /**
     * @var ConfigurationService
     */
    protected $config;

    public function __construct(
        ConfigurationService $config
    ) {
        $this->config = $config;
    }


    public function provideCommandInvocations(): Generator {
        yield [[], '[OK] All default values have the correct type', true];
    }

    public function provideWrongCommandInvocations(): Generator {
        yield [['argument' => 'value'],
               '[OK] All default values have the correct type',
               GlobalInvalidArgumentException::class];
    }

    public function testWrongBooleanExecute()
    {
        // First break something
        // var_dump(get_class_methods($this->config));
        //getConfigSpecification());
        self::assertTrue(true);
        $kernel = static::createKernel();
        $container = self::$kernel;
        $container->get('config');
        $application = new Application($kernel);
        $t = $application;
        /*$command = $application->find(static::$commandName);
        $commandTester = new CommandTester($command);
        $commandTester->execute($commandOptions);
        //var_dump(get_class_methods($commandTester));
        self::assertEquals($success, !(bool)$commandTester->getStatusCode());
        $output = $commandTester->getDisplay();
        self::assertStringContainsString($expectedOutput, $output);*/
    }


}

/*namespace App\Tests\Unit\Command;

use App\Tests\Unit\BaseTest as BaseTest;
use App\Command\CheckDatabaseConfigurationDefaultValuesCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;


class CheckDatabaseConfigurationDefaultValuesCommandTest extends BaseTest
{
    public function testDefaultUsage(): void {
        $command = static::$container->get(CheckDatabaseConfigurationDefaultValuesCommand::class);
        $input = new InputInterface();
        $output = new OutputInterface();
        var_dump(get_class_methods($command->execute($input, $output)));
    }*/

    /*public function DefaultUsage(): void {
        $command  = ['webapp/bin/console','domjudge:db-config:check'];
        $process  = new Process($command);
        $process->run();
        $out = $process->getOutput();
        self::assertTrue($process->isSuccessful());
        self::assertStringContainsString('[OK] All default values have the correct type', $out);
    }

    public function testHelpUsage(): void {
        $command  = ['webapp/bin/console','domjudge:db-config:check','-h'];
        $process  = new Process($command);
        $process->run();
        $out = $process->getOutput();
        self::assertTrue($process->isSuccessful());
        self::assertStringContainsString('Check if the default values of the database configuration are valid', $out);
    }

    public function testVerboseUsage(): void {
        $defaultCommand  = ['webapp/bin/console','domjudge:db-config:check'];
        $outputs = [];
        foreach (['-v','-vv','-vvv','--verbose'] as $flag) {
            $command = $defaultCommand+[$flag];
            $process  = new Process($command);
            $process->run();
            $out = $process->getOutput();
            self::assertTrue($process->isSuccessful());
            $outputs[] = $out;
        }
        foreach ($outputs as $output) {
            self::assertEquals($out, $output);
        }
    }*/
//}
