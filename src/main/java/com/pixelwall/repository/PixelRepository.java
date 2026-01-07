package com.pixelwall.repository;

import com.pixelwall.entity.pixel.Pixel;
import com.pixelwall.entity.pixel.PixelId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PixelRepository extends JpaRepository<Pixel, PixelId> {
}
