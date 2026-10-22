package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.com.entity.ComplexityCategory;

import java.util.List;
import java.util.Optional;

@Repository
public interface ComplexityCategoryRepository extends JpaRepository<ComplexityCategory, Long> {

    List<ComplexityCategory> findByTechnologyIdAndActiveTrueOrderBySortOrder(Long technologyId);

    Optional<ComplexityCategory> findByTechnologyIdAndCode(Long technologyId, String code);

    boolean existsByTechnologyIdAndCode(Long technologyId, String code);
}
