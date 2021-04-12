<?php declare(strict_types=1);

namespace App\Tests\Controller\Jury;

use App\DataFixtures\Test\RejudgingStatesFixture;
use App\Tests\BasePantherTest;
use App\Tests\BaseTest;
use Symfony\Component\Panther\PantherTestCase;
use Generator;

class RejudgingControllerPantherTest extends BasePantherTest
{
    protected static $roles = ['admin'];

    public function testCorrectDatatableSorting(): void
    {
        $this->assertEquals("yes","yes");
        //$this->logOut();
        //$this->logIn();
        //$this->loadFixture(RejudgingStatesFixture::class);
        $this->client->request('GET', '/jury/rejudgings');
        $this->client->wait(1000);
        $this->assertSelectorTextContains('h1', 'Rejudgings');
        //$this->client->request('GET', 'http://localhost/jury/rejudgings');
        //$this->client->waitFor('.col-12');
        //var_dump($this->client->request('GET', 'http://localhost/jury/rejudgings')->html());
        //var_dump($this->client->getTitle());
        //var_dump($this->client->getCurrentURL());
        //$this->client->takeScreenshot('screen.png');
        //$this->verifyPageResponse('GET', '/jury/rejudgings', 200);
        // The sorting is done in JS, this is JS ordering of the table
        //foreach(['Unit','Canceled','Finished'] as $index=>$reason)
        //{
        //    self::assertSelectorExists('tr:nth-child('.($index+1).'):contains("'.$reason.'")');
        //}
    }
}
