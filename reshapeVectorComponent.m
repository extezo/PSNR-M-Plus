function comp = reshapeVectorComponent(vectors, h, w, i)
    comp = reshape(vectors(i,:), w, h);
    comp = comp';
end