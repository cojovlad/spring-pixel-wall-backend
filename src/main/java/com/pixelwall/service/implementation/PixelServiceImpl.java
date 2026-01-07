package com.pixelwall.service.implementation;

import com.pixelwall.entity.pixel.Pixel;
import com.pixelwall.entity.pixel.PixelId;
import com.pixelwall.entity.pixel.PixelStatus;
import com.pixelwall.repository.PixelRepository;
import com.pixelwall.service.PixelService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@Transactional
public class PixelServiceImpl implements PixelService {

    private final PixelRepository pixelRepository;

    public PixelServiceImpl(PixelRepository pixelRepository) {
        this.pixelRepository = pixelRepository;
    }

    private PixelId makePixelId(short x, short y) {
        return new PixelId(x, y);
    }

    @Override
    public Optional<Pixel> getPixelById(short x, short y) {
        return pixelRepository.findById(makePixelId(x, y));
    }

    @Override
    public Optional<Pixel> addPixel(Pixel pixel) {
        return Optional.of(pixelRepository.save(pixel));
    }

    @Override
    public void updatePixel(short x, short y, PixelStatus pixelStatus) {
        pixelRepository.findById(makePixelId(x, y)).ifPresent(p -> {
            p.setStatus(pixelStatus);
            pixelRepository.save(p);
        });
    }

    @Override
    public void deletePixelById(short x, short y) {
        pixelRepository.deleteById(makePixelId(x, y));
    }
}