<?php declare(strict_types=1);

namespace App\Logger;

use App\Service\DOMJudgeService;
use Monolog\LogRecord;
use Symfony\Component\HttpFoundation\Exception\SessionNotFoundException;
use Symfony\Component\HttpFoundation\RequestStack;

class SessionRequestProcessor
{
    public function __construct(
        private RequestStack $requestStack,
        //private DOMJudgeService $dj
    ) {}

    // this method is called for each log record; optimize it to not hurt performance
    public function __invoke(LogRecord $record): LogRecord
    {
        $record->extra['token'] = "works";
        $record->extra['token2'] = "works";
        try {
            $session = $this->requestStack->getSession();
        } catch (SessionNotFoundException $e) {
            return $record;
        }

        if (!$session->isStarted()) {
            return $record;
        }

        $sessionId = substr($session->getId(), 0, 8) ?: '????????';
        $record->extra['token'] = $sessionId.'-'.substr(uniqid('', true), -8);
        $record->extra['token'] = "works";
        return $record;
    }
}
