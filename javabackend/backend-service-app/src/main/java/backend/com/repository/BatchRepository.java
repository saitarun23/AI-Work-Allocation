package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.com.entity.Batch;
import backend.com.entity.BatchStatus;

import java.util.List;

@Repository
public interface BatchRepository extends JpaRepository<Batch, Long> {

	List<Batch> findByStatus(BatchStatus status);

	List<Batch> findByClientId(Long clientId);

	List<Batch> findByStatusInOrderByDeadlineAsc(List<BatchStatus> statuses);
}
