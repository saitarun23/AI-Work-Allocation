package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.com.entity.Assignment;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface AssignmentRepository extends JpaRepository<Assignment, Long> {

    List<Assignment> findByPlanId(Long planId);

    List<Assignment> findByEmployeeIdAndPlannedDateBetween(Long employeeId, LocalDate from, LocalDate to);

    List<Assignment> findByWorkUnitId(Long workUnitId);
}
