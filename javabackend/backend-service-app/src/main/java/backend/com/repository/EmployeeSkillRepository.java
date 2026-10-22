package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import backend.com.entity.EmployeeSkill;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeSkillRepository extends JpaRepository<EmployeeSkill, Long> {

    List<EmployeeSkill> findByEmployeeId(Long employeeId);

    Optional<EmployeeSkill> findByEmployeeIdAndTechnologyId(Long employeeId, Long technologyId);

    /** The working team for a technology: active skills of active employees. */
    @Query("""
            select s from EmployeeSkill s
            join fetch s.employee e
            join fetch s.level
            where s.technology.id = :technologyId
              and s.active = true
              and e.active = true
            """)
    List<EmployeeSkill> findActiveTeam(@Param("technologyId") Long technologyId);
}