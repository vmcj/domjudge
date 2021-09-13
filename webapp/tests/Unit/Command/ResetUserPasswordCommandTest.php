<?php declare(strict_types=1);

namespace App\Tests\Unit\Command;

use Generator;
use RuntimeException;

class ResetUserPasswordCommandTest extends CommandTest
{
    protected static $commandName = 'domjudge:reset-user-password';

    public function provideCommandInvocations(): Generator {
        foreach(['admin','demo','judgehost'] as $user) {
            yield [['username' => $user], sprintf("[OK] New password for %s is", $user), true];
        }
        yield [['username' => 'notAUser'], '[ERROR] Can not find user with username notAUser', false];
    }
    
    public function provideWrongCommandInvocations(): Generator {
        yield [[], 'Not enough arguments (missing: "username").', RuntimeException::class];
    }
}