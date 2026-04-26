<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class HelloController
{
    #[Route('/', methods: ['GET'])]
    public function __invoke(): Response
    {
        $message = sprintf(
            "Hello from %s at %s\n",
            gethostname() ?: 'unknown',
            (new \DateTimeImmutable())->format(\DateTimeInterface::ATOM),
        );

        return new Response($message, Response::HTTP_OK, ['Content-Type' => 'text/plain; charset=utf-8']);
    }
}
