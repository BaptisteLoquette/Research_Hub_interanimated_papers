"""
Example Manim scene — requires Manim installed (see backend/requirements-visual.txt).
Render: manim -pqh backend/visuals/equation_scene.py EquationExplainer
"""
from manim import *  # noqa: F401,F403


class EquationExplainer(Scene):
    def construct(self):
        eq = MathTex(r"p(x) = \int p(x \mid z) p(z) \, dz")
        explanation = Tex(
            r"$p(x)$: marginal of data; $p(x\mid z)$: likelihood; $p(z)$: prior",
        ).scale(0.6).next_to(eq, DOWN)

        self.play(Write(eq))
        self.wait(1)
        self.play(FadeIn(explanation, shift=DOWN))
        self.wait(2)
