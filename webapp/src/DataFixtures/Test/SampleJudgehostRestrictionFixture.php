<?php declare(strict_types=1);

namespace App\DataFixtures\Test;

use App\Entity\JudgehostRestriction;
use Doctrine\Persistence\ObjectManager;

class SampleJudgehostRestrictionFixture extends AbstractTestDataFixture
{
    public function load(ObjectManager $manager): void
    {
        $restriction = (new JudgeHostRestriction())
            ->setName("NoRestriction")
            ->setRejudgeOwn(true);
        $manager->persist($restriction);
        $manager->flush();
    }
}
