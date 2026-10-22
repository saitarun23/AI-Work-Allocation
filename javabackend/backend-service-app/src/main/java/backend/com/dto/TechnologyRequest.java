package backend.com.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Data accepted when creating or updating a technology. active is optional (a new technology defaults to active). */
public record TechnologyRequest(
        @NotBlank
        @Size(max = 40)
        @Pattern(regexp = "^[A-Za-z0-9_]+$", message = "may contain only letters, digits and underscore")
        String code,

        @NotBlank
        @Size(max = 100)
        String name,

        Boolean active) {
}
