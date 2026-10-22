package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.com.entity.AllocationPlan;
import backend.com.entity.PlanStatus;

import java.util.List;
import java.util.Optional;

@Repository
public interface AllocationPlanRepository extends JpaRepository<AllocationPlan, Long> {

    Optional<AllocationPlan> findTopByBatchIdOrderByVersionDesc(Long batchId);

    List<AllocationPlan> findByBatchIdOrderByVersionDesc(Long batchId);

    List<AllocationPlan> findByStatus(PlanStatus status);
}
