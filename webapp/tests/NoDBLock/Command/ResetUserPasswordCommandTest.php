<?php declare(strict_types=1);

namespace App\Tests\Unit\Command;

use App\Tests\Unit\BaseTest as BaseTest;
use Symfony\Component\Process\Process;

class ResetUserPasswordCommandTest extends BaseTest
{

    public static $demoPassword = 'demo';

    public function testNonExistingUser(): void {
        $username = 'NotAnUser';
        $command  = ['webapp/bin/console','domjudge:reset-user-password',$username];
        $process  = new Process($command);
        $process->run();
        $out = $process->getOutput();
        self::assertFalse($process->isSuccessful());
        self::assertStringContainsString(sprintf('[ERROR] Can not find user with username %s', $username), $out);
    }

    public function testNoUser(): void {
        $command = ['webapp/bin/console','domjudge:reset-user-password'];
        $process = new Process($command);
        $process->run();
        $err = $process->getErrorOutput();
        self::assertFalse($process->isSuccessful());
        self::assertStringContainsStringIgnoringCase('Not enough arguments (missing: "username").', $err);
        self::assertStringContainsStringIgnoringCase('domjudge:reset-user-password [-h|--help]', $err);
    }

    public function apiRequest(string $password, int $statusCode, string $user = 'demo'): void {
        $server = ['CONTENT_TYPE' => 'application/json'];
        $server['PHP_AUTH_USER'] = $user;
        $server['PHP_AUTH_PW'] = $password;

        $this->client->request('GET', '/api/judgehosts',[],[],$server);
        $response = $this->client->getResponse();
        self::assertEquals($statusCode, $response->getStatusCode());
    }

    public function helperResetForUser(string $defaultPassword, string $user = 'demo'): string {
        $this->roles = ['admin'];
        $this->setupUser();
        $this->apiRequest($defaultPassword, 200);
        $command = ['webapp/bin/console','domjudge:reset-user-password',$user];
        $process = new Process($command);
        $ret = $process->run();
        $out = $process->getOutput();
        $passwordPosition = 7;
        $newPassword = explode(' ',$out)[$passwordPosition];
        return $newPassword;
    }

    public function testApiUser(): void {
        $defaultPassword = self::$demoPassword;
        $newPassword = $this->helperResetForUser($defaultPassword);
        $this->apiRequest($defaultPassword, 401);
        $this->apiRequest($newPassword, 200);
        self::$demoPassword = $newPassword;
    }

    public function testApiUserNoResetOtherUser(): void {
        $adminPasswordFile = sprintf(
            '%s/%s',
            static::$container->getParameter('domjudge.etcdir'),
            'initial_admin_password.secret'
        );
        $adminPassword = trim(file_get_contents($adminPasswordFile));
        $newDemoPassword = $this->helperResetForUser(self::$demoPassword);
        $this->apiRequest($adminPassword, 200, 'admin');
        $this->apiRequest($newDemoPassword, 401, 'admin');
        self::$demoPassword = $newDemoPassword;
    }
}
