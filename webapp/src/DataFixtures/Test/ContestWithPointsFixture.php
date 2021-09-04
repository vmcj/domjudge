<?php declare(strict_types=1);

namespace App\DataFixtures\Test;

use App\Entity\Contest;
use App\Entity\ContestProblem;
use Doctrine\Persistence\ObjectManager;

class ContestWithPointsFixture extends AbstractTestDataFixture
{
    public function load(ObjectManager $manager)
    {
        $onePoint = new ContestProblem();
        $onePoint->setShortname('onePoint')
                 ->setPoints(1);
        $twoPoint = new ContestProblem();
        $twoPoint->setShortname('twoPoint')
                 ->setPoints(2);
        $manager->persist($onePoint);
        $manager->persist($twoPoint);
        $manager->flush();
        $contest = new Contest();
        $name = 'ContestWithPoints';
        $contest->setName($name)
                ->setShortname($name)
                ->setActivatetimeString('2000-01-01T01:00:00')
                ->setStartTimeString('2000-01-02T01:00:00')
                ->setEndTimeString('2000-01-03T01:00:00')
                ->addProblem($onePoint)
                ->addProblem($twoPoint);
        $manager->persist($contest);
        $manager->flush();
    }
}
