package com.pixelwall.repository;

import com.pixelwall.entity.pixel.PixelId;
import com.pixelwall.entity.pixel.PixelMetadata;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PixelMetadataRepository extends JpaRepository<PixelMetadata, PixelId> {
}
