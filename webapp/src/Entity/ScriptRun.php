<?php declare(strict_types=1);
namespace App\Entity;

use App\Utils\Utils;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use JMS\Serializer\Annotation as Serializer;

/**
 * Result of a Script task run.
 */
#[ORM\Entity]
#[ORM\Table(options: [
    'collation' => 'utf8mb4_unicode_ci',
    'charset' => 'utf8mb4',
    'comment' => 'Result of a general script ran on the judgehost',
])]
class ScriptRun extends BaseApiEntity
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(options: ['comment' => 'Run ID', 'unsigned' => true])]
    #[Serializer\SerializedName('id')]
    #[Serializer\Type('string')]
    protected int $runid;

    #[ORM\Column(
        nullable: true,
        options: ['comment' => 'JudgeTask ID', 'unsigned' => true, 'default' => null]
    )]
    #[Serializer\Exclude]
    private ?int $judgetaskid = null;

    #[ORM\Column(
        length: 32,
        nullable: true,
        options: ['comment' => 'Result of this run, NULL if not finished yet']
    )]
    #[Serializer\Exclude]
    private ?string $runresult = null;

    #[ORM\Column(
        nullable: true,
        options: ['comment' => 'Submission running time on this testcase']
    )]
    #[Serializer\Exclude]
    private string|float|null $runtime = null;

    #[ORM\Column(
        type: 'decimal',
        precision: 32,
        scale: 9,
        nullable: true,
        options: ['comment' => 'Time run ended', 'unsigned' => true]
    )]
    #[Serializer\Exclude]
    private string|float|null $endtime = null;

    #[ORM\Column(
        type: 'decimal',
        precision: 32,
        scale: 9,
        nullable: true,
        options: ['comment' => 'Time run started', 'unsigned' => true]
    )]
    #[Serializer\Exclude]
    private string|float|null $startTime = null;

    /**
     * @var Collection<int, ScriptRunOutput>
     *
     * We use a OneToMany instead of a OneToOne here, because otherwise this
     * relation will always be loaded. See the commit message of commit
     * 9e421f96691ec67ed62767fe465a6d8751edd884 for a more elaborate explanation
     */
    #[ORM\OneToMany(mappedBy: 'run', targetEntity: ScriptRunOutput::class, cascade: ['persist'], orphanRemoval: true)]
    #[Serializer\Exclude]
    private Collection $output;

    #[ORM\ManyToOne(inversedBy: 'judging_runs')]
    #[ORM\JoinColumn(name: 'judgetaskid', referencedColumnName: 'judgetaskid', onDelete: 'CASCADE')]
    #[Serializer\Exclude]
    private ?JudgeTask $judgetask = null;

    public function __construct()
    {
        $this->output = new ArrayCollection();
    }

    public function setJudgeTaskId(int $judgetaskid): ScriptRun
    {
        $this->judgetaskid = $judgetaskid;
        return $this;
    }

    public function getJudgeTaskId(): ?int
    {
        return $this->judgetaskid;
    }

    public function getJudgeTask(): ?JudgeTask
    {
        return $this->judgetask;
    }

    public function setJudgeTask(JudgeTask $judgeTask): ScriptRun
    {
        $this->judgetask = $judgeTask;
        return $this;
    }

    public function setRunresult(string $runresult): ScriptRun
    {
        $this->runresult = $runresult;
        return $this;
    }

    public function getRunresult(): ?string
    {
        return $this->runresult;
    }

    public function setRuntime(string|float $runtime): ScriptRun
    {
        $this->runtime = $runtime;
        return $this;
    }

    #[Serializer\VirtualProperty]
    #[Serializer\SerializedName('run_time')]
    #[Serializer\Type('float')]
    public function getRuntime(): string|float|null
    {
        return Utils::roundedFloat($this->runtime);
    }

    public function setEndtime(string|float $endtime): ScriptRun
    {
        $this->endtime = $endtime;
        return $this;
    }

    public function setStarttime(string|float $startTime): ScriptRun
    {
        $this->startTime = $startTime;
        return $this;
    }

    public function getStarttime(): string|float|null
    {
        return $this->startTime;
    }

    public function getEndtime(): string|float|null
    {
        return $this->endtime;
    }

    #[Serializer\VirtualProperty]
    #[Serializer\SerializedName('time')]
    #[Serializer\Type('string')]
    public function getAbsoluteEndTime(): string
    {
        return Utils::absTime($this->getEndtime());
    }

    #[Serializer\VirtualProperty]
    #[Serializer\SerializedName('contest_time')]
    #[Serializer\Type('string')]
    public function getRelativeEndTime(): string
    {
        return Utils::relTime($this->getEndtime() - $this->getJudging()->getContest()->getStarttime());
    }

    public function setJudging(?Judging $judging = null): ScriptRun
    {
        $this->judging = $judging;
        return $this;
    }

    public function getJudging(): Judging
    {
        return $this->judging;
    }

    #[Serializer\VirtualProperty]
    #[Serializer\SerializedName('judgement_id')]
    #[Serializer\Type('string')]
    public function getJudgingId(): int
    {
        return $this->getJudging()->getJudgingid();
    }

    public function setOutput(JudgingRunOutput $output): ScriptRun
    {
        $this->output->clear();
        $this->output->add($output);
        $output->setRun($this);

        return $this;
    }

    public function getOutput(): ?JudgingRunOutput
    {
        return $this->output->first() ?: null;
    }
}
