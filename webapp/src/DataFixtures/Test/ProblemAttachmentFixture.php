<?php declare(strict_types=1);

namespace App\DataFixtures\Test;

use App\Entity\Problem;
use App\Entity\ProblemAttachment;
use App\Entity\ProblemAttachmentContent;
use Doctrine\Persistence\ObjectManager;

class ProblemAttachmentFixture extends AbstractTestDataFixture
{
    public function load(ObjectManager $manager): void
    {
        /** @var Problem $problem */
        $problem = $manager->getRepository(Problem::class)->findOneBy(['externalid' => 'boolfind']);
        $attachment = (new ProblemAttachment())
            ->setName('interactor')
            ->setType('py')
            ->setProblem($problem);
        $manager->persist($attachment);
        $manager->flush();
        $content = (new ProblemAttachmentContent())
            ->setAttachment($attachment)
            ->setContent(file_get_contents(__DIR__ . '/../../../../testdata/boolfind.py'));
        $manager->persist($content);
        $manager->persist($attachment);
        $manager->flush();
        $problem->addAttachment($attachment);
        $manager->persist($problem);
        $manager->persist($content);
        $manager->persist($attachment);
        $manager->flush();
    }
}
