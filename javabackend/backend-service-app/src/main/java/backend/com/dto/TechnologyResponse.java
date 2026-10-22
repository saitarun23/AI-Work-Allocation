package backend.com.dto;

import java.time.LocalDateTime;

public record TechnologyResponse(
        Long id,
        String code,
        String name,
        boolean active,
        LocalDateTime createdAt) {
}
