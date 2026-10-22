package backend.com.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.com.entity.Technology;

import java.util.List;
import java.util.Optional;

@Repository
public interface TechnologyRepository extends JpaRepository<Technology, Long> {

    Optional<Technology> findByCode(String code);

    boolean existsByCode(String code);

    List<Technology> findByActiveTrue();
}
