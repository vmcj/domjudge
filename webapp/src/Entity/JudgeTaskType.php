<?php declare(strict_types=1);

namespace App\Entity;

enum JudgeTaskType: string
{
    case CONFIG_CHECK = 'config_check';
    case DEBUG_INFO = 'debug_info';
    case GENERIC_TASK = 'generic_task';
    case JUDGING_RUN = 'judging_run';
    case PREFETCH = 'prefetch';

    public static function getColumnDefinition(): string
    {
        return 'ENUM(' . implode(', ', array_column(self::cases(), 'value'));
    }
}
