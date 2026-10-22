package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.com.entity.WorkUnit;

import java.util.List;

@Repository
public interface WorkUnitRepository extends JpaRepository<WorkUnit , Long> {

	List<WorkUnit> findByBatchId(Long batchId);
}
