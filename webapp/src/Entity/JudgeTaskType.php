<?php declare(strict_types=1);

namespace App\Entity;

enum JudgeTaskType: string
{
    case ConfigCheck = 'config_check';
    case DebugInfo = 'debug_info';
    case GenericTask = 'generic_task';
    case JudgingRun = 'judging_run';
    case Prefetch = 'prefetch';

    public static function getColumnDefinition(): string
    {
        return 'ENUM(' . implode(', ', array_column(self::cases(), 'value'));
    }
}
