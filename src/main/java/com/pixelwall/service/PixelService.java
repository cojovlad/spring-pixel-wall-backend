package com.pixelwall.service;

import com.pixelwall.entity.pixel.Pixel;
import com.pixelwall.entity.pixel.PixelStatus;
import com.pixelwall.repository.PixelRepository;

import java.util.List;
import java.util.Optional;

public interface PixelService {
    Optional<Pixel> getPixelById(short x, short y);
    Optional<Pixel> addPixel(Pixel pixel);
    void updatePixel(short x, short y, PixelStatus pixelStatus);
    void deletePixelById(short x, short y);
}
