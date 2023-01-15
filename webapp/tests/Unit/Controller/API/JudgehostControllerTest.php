<?php declare(strict_types=1);

namespace App\Tests\Unit\Controller\API;

use App\DataFixtures\Test\ExampleJudgeTaskFixture;
use App\Entity\JudgeTask;
use Generator;

class JudgehostControllerTest extends BaseTestCase
{
    protected ?string $apiEndpoint   = 'judgehosts';
    protected ?string $apiUser       = 'admin';
    protected static array $fixtures = [ExampleJudgeTaskFixture::class];

    protected static string $skipMessageCI  = "This is very dependent on the contributor setup, check this in CI.";
    protected static string $skipMessageIDs = "Filtering on IDs not implemented in this endpoint.";

    protected array $expectedObjects = [];

    protected array $expectedAbsent = ['4242', 'nonexistent'];

    public function testList(): void
    {
        if (getenv("CI")) {
            parent::testList();
        } else {
            static::markTestSkipped(static::$skipMessageCI);
        }
    }

    public function testListWithIds(): void
    {
        static::markTestSkipped(static::$skipMessageIDs);
    }

    public function testListWithIdsNotArray(): void
    {
        static::markTestSkipped(static::$skipMessageIDs);
    }

    public function testListWithAbsentIds(): void
    {
        static::markTestSkipped(static::$skipMessageIDs);
    }

    public function provideSingle(): Generator
    {
        foreach ($this->expectedObjects as $expectedProperties) {
            yield [$expectedProperties['hostname'], $expectedProperties];
        }
    }

    /**
     * Test that the endpoint returns an empty list for objects that don't exist.
     *
     * @dataProvider provideSingleNotFound
     */
    public function testSingleNotFound(string $id): void
    {
        $id = $this->resolveReference($id);
        $url = $this->helperGetEndpointURL($this->apiEndpoint, $id);
        $object = $this->verifyApiJsonResponse('GET', $url, 200, $this->apiUser);
        static::assertEquals([], $object);
    }

    public function testAddJudgehost(): void
    {
        $judgehostPostData = ['hostname' => 'newJudgehost'];
        $url = $this->helperGetEndpointURL('judgehosts');
        $currentJudgehosts =  $this->verifyApiJsonResponse('GET', $url, 200, 'admin');
        $unfinished = $this->verifyApiJsonResponse('POST', $url, 200, 'admin', $judgehostPostData);
        self::assertEquals([], $unfinished);
        $newJudgehosts =  $this->verifyApiJsonResponse('GET', $url, 200, 'admin');
        self::assertEquals(count($currentJudgehosts) + 1, count($newJudgehosts));
        $newItems = array_map('unserialize', array_diff(array_map('serialize', $newJudgehosts), array_map('serialize', $currentJudgehosts)));
        self::assertEquals(1, count($newItems));
        $listKey = array_keys($newItems)[0];
        foreach ($judgehostPostData as $key => $value) {
            self::assertEquals($newItems[$listKey][$key], $value);
        }
    }

    /*public function testEnabledJudgehost(): void
    {
        $this->testAddJudgehost();
        $url = $this->helperGetEndpointURL('judgehosts').'/newJudgehost';
        $returnedJudgehost = $this->verifyApiJsonResponse('PUT', $url, 200, 'admin', ['enabled' => True])[0];
        var_dump($returnedJudgehost);
        self::assertEquals(True, $returnedJudgehost['enabled']);
        $returnedJudgehost = $this->verifyApiJsonResponse('PUT', $url, 200, 'admin', ['enabled' => False]);
        self::assertEquals(False, $returnedJudgehost['enabled']);
        $returnedJudgehost = $this->verifyApiJsonResponse('PUT', $url, 200, 'admin', ['enabled' => True]);
        self::assertEquals(True, $returnedJudgehost['enabled']);
    }

    public function testUpdateJudging(): void
    {
        $url = $this->helperGetEndpointURL('judgehosts').'/update-judging/example-judgehost1/1';
        $returnedJudgehost = $this->verifyApiJsonResponse('PUT', $url, 200, 'admin',
            ['compile_success' => True, 'output_compile' => 'The compile output', 'entry_point' => 'Entry_point', 'compile_metadata' => 'The compile metadata']
        );
        self::assertNull($returnedJudgehost);
    }*/

    
    /**
     * @dataProvider provideNonExistant
     */
    public function testAddDebugJudging(string $hostname, int $httpStatus, ?string $judgeTaskId): void
    {
        if (!$judgeTaskId) {
            $judgeTaskId = $this->resolveReference(ExampleJudgeTaskFixture::class . ':0');
        }
        $url = $this->helperGetEndpointURL('judgehosts').'/add-debug-info/'.$hostname.'/'.$judgeTaskId;
        $this->verifyApiJsonResponse('POST', $url, $httpStatus, 'admin', ['output_run' => 'out']);
    }

    public function provideNonExistant(): Generator
    {
        yield ['example-judgehost1', 200, null];
        yield ['unknown-judgehost1', 200, null];
        yield ['example-judgehost1', 400, '9999'];
        yield ['unknown-judgehost1', 400, '9999'];
    }
}
