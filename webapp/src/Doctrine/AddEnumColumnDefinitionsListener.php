<?php declare(strict_types=1);

namespace App\Doctrine;

use Doctrine\Bundle\DoctrineBundle\Attribute\AsDoctrineListener;
use Doctrine\ORM\Event\LoadClassMetadataEventArgs;
use Doctrine\ORM\Events;
use UnitEnum;

#[AsDoctrineListener(event: Events::loadClassMetadata)]
class AddEnumColumnDefinitionsListener
{
    public function __invoke(LoadClassMetadataEventArgs $eventArgs)
    {
        $classMetadata = $eventArgs->getClassMetadata();
        foreach ($classMetadata->getFieldNames() as $fieldName) {
            $field = $classMetadata->getFieldMapping($fieldName);
            if (isset($field['enumType'])) {
                /** @var UnitEnum $enumClass */
                $enumClass = $field['enumType'];
                $cases = array_map(
                    fn($case) => "'$case->value'",
                    $enumClass::cases()
                );
                $field['columnDefinition'] = sprintf('ENUM(%s)', implode(', ', $cases));
                $classMetadata->fieldMappings[$fieldName] = $field;
            }
        }
    }
}
