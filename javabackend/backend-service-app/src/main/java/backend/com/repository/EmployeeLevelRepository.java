package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.com.entity.EmployeeLevel;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeLevelRepository extends JpaRepository<EmployeeLevel, Long> {

    Optional<EmployeeLevel> findByCode(String code);

    boolean existsByCode(String code);

    List<EmployeeLevel> findByActiveTrueOrderByRankOrderDesc();
}
