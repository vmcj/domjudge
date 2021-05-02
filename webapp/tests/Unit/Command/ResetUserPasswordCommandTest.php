<?php declare(strict_types=1);

namespace App\Tests\Unit\Command;

use App\Tests\Unit\BaseTest as BaseTest;
use Symfony\Component\Process\Process;

class ResetUserPasswordCommandTest extends BaseTest
{
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

    public function apiRequest(string $password, $statusCode): void {
        $server = ['CONTENT_TYPE' => 'application/json'];
        $server['PHP_AUTH_USER'] = 'demo';
        $server['PHP_AUTH_PW'] = $password;
        $this->client->request('GET', '/api/judgehosts',[],[],$server);
        $response = $this->client->getResponse();
        self::assertEquals($statusCode, $response->getStatusCode());
    }

    public function testApiUser(): void {
        $defaultPassword = 'demo';
        $this->roles = ['admin'];
        $this->setupUser();
        $this->apiRequest($defaultPassword, 200);
        $command = ['webapp/bin/console','domjudge:reset-user-password','demo'];
        $process = new Process($command);
        $process->run();
        $out = $process->getOutput();
        $passwordPosition = 7;
        $newPassword = explode(' ',$out)[$passwordPosition];
        $this->apiRequest($defaultPassword, 401);
        $this->apiRequest($newPassword, 200);
    }
}
