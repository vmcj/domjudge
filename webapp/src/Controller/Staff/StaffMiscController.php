<?php declare(strict_types=1);

namespace App\Controller\Staff;

use App\Controller\BaseController;
use App\Entity\Contest;
use App\Entity\Judging;
use App\Entity\Language;
use App\Entity\Problem;
use App\Entity\Submission;
use App\Entity\Team;
use App\Entity\TeamAffiliation;
use App\Service\DOMJudgeService;
use App\Service\ScoreboardService;
use App\Utils\Utils;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Query\Expr\Join;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\IsGranted;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Security;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Routing\RouterInterface;

/**
 * Class StaffMiscController
 *
 * @Route("/staff")
 * @IsGranted("ROLE_STAFF")
 *
 * @package App\Controller\Staff
 */
class StaffMiscController extends BaseController
{
    protected EntityManagerInterface $em;
    protected DOMJudgeService $dj;

    /**
     * GeneralInfoController constructor.
     */
    public function __construct(EntityManagerInterface $entityManager, DOMJudgeService $dj)
    {
        $this->em = $entityManager;
        $this->dj = $dj;
    }

    /**
     * @Route("", name="staff_index")
     */
    public function indexAction(): Response
    {
        return $this->render('staff/index.html.twig');
    }

    /**
     * @Route("/updates", methods={"GET"}, name="staff_ajax_updates")
     * @Security("is_granted('ROLE_JURY') or is_granted('ROLE_BALLOON')")
     */
    public function updatesAction(): JsonResponse
    {
        return $this->json($this->dj->getUpdates());
    }

    /**
     * @Route("/ajax/{datatype}", methods={"GET"}, name="staff_ajax_data")
     * @Security("is_granted('ROLE_JURY') or is_granted('ROLE_BALLOON')")
     */
    public function ajaxDataAction(Request $request, string $datatype): JsonResponse
    {
        $q  = $request->query->get('q');
        $qb = $this->em->createQueryBuilder();

        if ($datatype === 'affiliations') {
            $affiliations = $qb->from(TeamAffiliation::class, 'a')
                ->select('a.affilid', 'a.name', 'a.shortname')
                ->where($qb->expr()->like('a.name', '?1'))
                ->orWhere($qb->expr()->like('a.shortname', '?1'))
                ->orWhere($qb->expr()->eq('a.affilid', '?2'))
                ->orderBy('a.name', 'ASC')
                ->getQuery()->setParameter(1, '%' . $q . '%')
                ->setParameter(2, $q)
                ->getResult();

            $results = array_map(function (array $affiliation) {
                $displayname = $affiliation['name'] . " (" . $affiliation['affilid'] . ")";
                return [
                    'id' => $affiliation['affilid'],
                    'text' => $displayname,
                ];
            }, $affiliations);
        } elseif ($datatype === 'locations') {
            $locations = $qb->from(Team::class, 'a')
                ->select('DISTINCT a.room')
                ->where($qb->expr()->like('a.room', '?1'))
                ->orderBy('a.room', 'ASC')
                ->getQuery()->setParameter(1, '%' . $q . '%')
                ->getResult();

            $results = array_map(fn(array $location) => [
                'id' => $location['room'],
                'text' => $location['room']
            ], $locations);
        } elseif (!$this->isGranted('ROLE_JURY')) {
            throw new AccessDeniedHttpException('Permission denied');
        } elseif ($datatype === 'problems') {
            $problems = $qb->from(Problem::class, 'p')
                ->select('p.probid', 'p.name')
                ->where($qb->expr()->like('p.name', '?1'))
                ->orWhere($qb->expr()->eq('p.probid', '?2'))
                ->orderBy('p.name', 'ASC')
                ->getQuery()->setParameter(1, '%' . $q . '%')
                ->setParameter(2, $q)
                ->getResult();

            $results = array_map(function (array $problem) {
                $displayname = $problem['name'] . " (p" . $problem['probid'] . ")";
                return [
                    'id' => $problem['probid'],
                    'text' => $displayname,
                ];
            }, $problems);
        } elseif ($datatype === 'teams') {
            $teams = $qb->from(Team::class, 't')
                ->select('t.teamid', 't.display_name', 't.name', 'COALESCE(t.display_name, t.name) AS order')
                ->where($qb->expr()->like('t.name', '?1'))
                ->orWhere($qb->expr()->like('t.display_name', '?1'))
                ->orWhere($qb->expr()->eq('t.teamid', '?2'))
                ->orderBy('order', 'ASC')
                ->getQuery()->setParameter(1, '%' . $q . '%')
                ->setParameter(2, $q)
                ->getResult();

            $results = array_map(function (array $team) {
                $displayname = ($team['display_name'] ?? $team['name']) . " (t" . $team['teamid'] . ")";
                return [
                    'id' => $team['teamid'],
                    'text' => $displayname,
                ];
            }, $teams);
        } elseif ($datatype === 'languages') {
            $languages = $qb->from(Language::class, 'l')
                ->select('l.langid', 'l.name')
                ->where($qb->expr()->like('l.name', '?1'))
                ->orWhere($qb->expr()->eq('l.langid', '?2'))
                ->orderBy('l.name', 'ASC')
                ->getQuery()->setParameter(1, '%' . $q . '%')
                ->setParameter(2, $q)
                ->getResult();

            $results = array_map(function (array $language) {
                $displayname = $language['name'] . " (" . $language['langid'] . ")";
                return [
                    'id' => $language['langid'],
                    'text' => $displayname,
                ];
            }, $languages);
        } elseif ($datatype === 'contests') {
            $query = $qb->from(Contest::class, 'c')
                ->select('c.cid', 'c.name', 'c.shortname')
                ->where($qb->expr()->like('c.name', '?1'))
                ->orWhere($qb->expr()->like('c.shortname', '?1'))
                ->orWhere($qb->expr()->eq('c.cid', '?2'))
                ->orderBy('c.name', 'ASC');

            if ($request->query->get('public') !== null) {
                $query = $query->andWhere($qb->expr()->eq('c.public', '?3'));
            }
            $query = $query->getQuery()
                ->setParameter(1, '%' . $q . '%')
                ->setParameter(2, $q);
            if ($request->query->get('public') !== null) {
                $query = $query->setParameter(3, $request->query->get('public'));
            }
            $contests = $query->getResult();

            $results = array_map(function (array $contest) {
                $displayname = $contest['name'] . " (" . $contest['shortname'] . " - c" . $contest['cid'] . ")";
                return [
                    'id' => $contest['cid'],
                    'text' => $displayname,
                ];
            }, $contests);
        } else {
            throw new NotFoundHttpException("Unknown AJAX data type: " . $datatype);
        }

        return $this->json(['results' => $results]);
    }

    /**
     * @Route("/change-contest/{contestId<-?\d+>}", name="staff_change_contest")
     */
    public function changeContestAction(Request $request, RouterInterface $router, int $contestId): Response
    {
        return $this->helperChangeContestAction($request, $router, $contestId, 'staff_index');
    }
}