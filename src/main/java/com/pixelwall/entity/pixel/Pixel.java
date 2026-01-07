package com.pixelwall.entity.pixel;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;

@Data
@Entity
@Table(name = "pixels")
public class Pixel {

    @EmbeddedId
    private PixelId id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PixelStatus status = PixelStatus.FREE;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    public PixelStatus getStatus() {
        return status;
    }
    public void setStatus(PixelStatus status) {
        this.status = status;
    }
}