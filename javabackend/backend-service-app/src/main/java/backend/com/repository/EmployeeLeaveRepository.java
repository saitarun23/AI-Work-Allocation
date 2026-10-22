package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.com.entity.EmployeeLeave;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;

@Repository
public interface EmployeeLeaveRepository extends JpaRepository<EmployeeLeave, Long> {

    List<EmployeeLeave> findByEmployeeIdAndLeaveDateBetween(Long employeeId, LocalDate from, LocalDate to);

    List<EmployeeLeave> findByEmployeeIdInAndLeaveDateBetween(Collection<Long> employeeIds, LocalDate from, LocalDate to);
}
