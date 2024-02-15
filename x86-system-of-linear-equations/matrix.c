#include <stdio.h>
#include <math.h>

// A[i][j] = i*(n+1) + j;

#define MAXN 1000

void partialPivot(int n, double A[n][n + 1])
{
    for (int i = 0; i < n; i++)
    {
        int pivotRow = i;
        int foundnz = 0;
        for (int j = i; j < n; j++)
        {
            if (fabs(A[j][i]) > 1e-6 )
                foundnz = 1;
            if (fabs(A[j][i]) > fabs(A[pivotRow][i]))
                pivotRow = j;
        }
        if(foundnz == 0) {
            printf("No unique solution\n");
            return;
        }
        if (pivotRow != i)
        {
            for (int j = i; j <= n; j++)
            {
                double temp = A[i][j];
                A[i][j] = A[pivotRow][j];
                A[pivotRow][j] = temp;
            }
        }

        for (int j = i + 1; j < n; j++)
        {
            double factor = A[j][i] / A[i][i];
            for (int k = i; k <= n; k++)
            {
                A[j][k] -= factor * A[i][k];
            }
        }
    }
}

void backSubstitute(int n, double A[n][n + 1], double x[n])
{
    for (int i = n - 1; i >= 0; i--)
    {
        double sum = 0;
        for (int j = i + 1; j < n; j++)
        {
            sum += A[i][j] * x[j];
        }
        x[i] = (A[i][n] - sum) / A[i][i];
    }
}

int main()
{
    int n = 4;
    // double A[2][3] = {{1.0, 1.0, 3.0},
    //                   {2.0, 2.0, 1.0}};
    double A[4][5] = {{1,2,3,0, 4}, {0,-4,-4,3, -8}, {0,0,-1,2, 8}, {0,0,0,1, -22}};               
    double x[MAXN];

    partialPivot(n, A);
    backSubstitute(n, A, x);

    printf("Solution for the system:\n");
    for (int i = 0; i < n; i++)
    {
        printf("%f\n", x[i]);
    }
}
